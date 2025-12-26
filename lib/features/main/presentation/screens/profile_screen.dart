import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:class_code/core/stubs/html_stub.dart' as html if (dart.library.html) 'dart:html';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/services/bunny_storage_service.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../../../../core/router/app_routers.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/profile_info_item.dart';
import '../widgets/subscription_info_card.dart';

/// شاشة الملف الشخصي
/// تعرض معلومات المستخدم وتمكنه من تعديل صورة الملف الشخصي وتسجيل الخروج
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// ImagePicker instance لاختيار الصور
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingImage = false;

  /// اختيار صورة ورفعها إلى Bunny Storage
  ///
  /// الخطوات:
  /// 1. فتح معرض الصور
  /// 2. رفع الصورة إلى Bunny Storage
  /// 3. تحديث profileImageUrl في Firestore
  /// 4. تحديث imagePath في UserCubit برابط الصورة من Bunny Storage
  /// 5. في حالة حدوث خطأ، عرض رسالة خطأ للمستخدم
  Future<void> _pickImage() async {
    try {
      final userCubit = context.read<UserCubit>();
      final userCode = userCubit.state.code;

      if (userCode == null || userCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن رفع الصورة: الكود غير موجود'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      try {
        setState(() {
          _isUploadingImage = true;
        });

        Uint8List? imageBytes;
        String fileName;

        if (kIsWeb) {
          // للويب: استخدام HTML File API
          final input = html.FileUploadInputElement()
            ..accept = 'image/*'
            ..style.display = 'none';

          html.document.body!.append(input as dynamic);

          final completer = Completer<html.File?>();
          StreamSubscription? onChangeSubscription;
          bool isCompleted = false;

          // ربط الـ listener قبل click
          onChangeSubscription = input.onChange.listen((event) {
            if (isCompleted) return; // تجنب الاستدعاء المتعدد
            isCompleted = true;
            
            debugPrint('📝 onChange event triggered');
            final files = input.files;
            if (files != null && files.isNotEmpty) {
              debugPrint('✅ ملف تم اختياره: ${files.first.name}');
              completer.complete(files.first);
            } else {
              debugPrint('⚠️ لا توجد ملفات في input');
              completer.complete(null);
            }
            
            // تنظيف
            onChangeSubscription?.cancel();
            try {
              input.remove();
            } catch (e) {
              debugPrint('⚠️ خطأ في إزالة input: $e');
            }
          });

          // إضافة delay صغير لضمان ربط الـ listener
          await Future.delayed(const Duration(milliseconds: 50));

          // فتح dialog اختيار الملف
          debugPrint('🖱️ فتح dialog اختيار الملف...');
          input.click();

          // انتظار اختيار المستخدم
          debugPrint('⏳ انتظار اختيار المستخدم للملف...');
          final htmlFile = await completer.future.timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              debugPrint('⏰ انتهت مهلة انتظار اختيار الملف');
              isCompleted = true;
              onChangeSubscription?.cancel();
              try {
                input.remove();
              } catch (e) {
                debugPrint('⚠️ خطأ في إزالة input بعد timeout: $e');
              }
              return null;
            },
          );

          if (!mounted) return;

          if (htmlFile == null) {
            setState(() {
              _isUploadingImage = false;
            });
            return;
          }

          // إنشاء اسم ملف فريد في مجلد students
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final originalExtension = htmlFile.name.split('.').last.toLowerCase();
          final extension = originalExtension.isEmpty ? 'jpg' : originalExtension;
          final cleanCode = userCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
          fileName = 'students/student_${cleanCode}_$timestamp.$extension';

          final reader = html.FileReader();
          final bytesCompleter = Completer<Uint8List>();

          reader.onLoad.listen((_) {
            try {
              final result = reader.result;
              if (result == null) {
                bytesCompleter.completeError(Exception('فشل قراءة الملف'));
                return;
              }

              Uint8List bytes;
              if (result is ByteBuffer) {
                bytes = result.asUint8List();
              } else if (result is TypedData) {
                bytes = Uint8List.view(result.buffer);
              } else if (result is List<int>) {
                bytes = Uint8List.fromList(result);
              } else {
                final arrayBuffer = result as dynamic;
                bytes = Uint8List.view(arrayBuffer);
              }
              bytesCompleter.complete(bytes);
            } catch (e) {
              bytesCompleter.completeError(Exception('فشل قراءة الملف: $e'));
            }
          });

          reader.onError.listen((error) {
            bytesCompleter.completeError(error);
          });

          reader.readAsArrayBuffer(htmlFile);
          imageBytes = await bytesCompleter.future;
        } else {
          // للـ iOS و Android: استخدام image_picker
          final XFile? image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 85,
          );

          if (!mounted) return;

          if (image == null) {
            setState(() {
              _isUploadingImage = false;
            });
            return;
          }

          final file = File(image.path);
          if (await file.exists()) {
            imageBytes = await file.readAsBytes();
            // إنشاء اسم ملف فريد في مجلد students
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final extension = image.path.split('.').last.toLowerCase();
            final cleanCode = userCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
            fileName = 'students/student_${cleanCode}_$timestamp.$extension';
          } else {
            setState(() {
              _isUploadingImage = false;
            });
            return;
          }
        }

        // رفع الصورة إلى Bunny Storage
        final imageUrl = await BunnyStorageService.uploadImage(
          imageBytes: imageBytes,
          fileName: fileName,
        );

        // تحديث Firestore
        await InjectionContainer.adminRepo.updateCodeImageUrl(
          userCode,
          imageUrl,
        );

        // تحديث UserCubit
        await userCubit.updateUser(imagePath: imageUrl);

        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم رفع الصورة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('خطأ في رفع صورة الطالب: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل رفع الصورة: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isUploadingImage = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء اختيار الصورة: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// معالجة تسجيل الخروج
  ///
  /// الخطوات:
  /// 1. إزالة ربط الجهاز من الكود في Firestore
  /// 2. مسح جميع بيانات المستخدم من UserCubit
  /// 3. عرض رسالة نجاح
  /// 4. إعادة التوجيه لشاشة تسجيل الدخول
  Future<void> _handleLogout() async {
    if (!mounted) return;

    final userCubit = context.read<UserCubit>();
    final userCode = userCubit.state.code;

    // إزالة ربط الجهاز من الكود في Firestore (إذا كان هناك كود)
    if (userCode != null && userCode.isNotEmpty) {
      try {
        final authDataSource = InjectionContainer.authRemoteDataSource as dynamic;
        if (authDataSource is AuthRemoteDataSourceImpl) {
          await authDataSource.logoutWithCode(userCode);
        }
      } catch (e) {
        debugPrint('❌ خطأ في إزالة ربط الجهاز: $e');
        // نستمر في تسجيل الخروج حتى لو فشل تحديث deviceId
      }
    }

    // مسح جميع بيانات المستخدم من UserCubit
    await userCubit.clearUserData();

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم تسجيل الخروج')));
      // إعادة التوجيه لصفحة تسجيل الدخول
      context.go(AppRouters.codeInputScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = isWeb && screenWidth > 800;
    
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) =>
          previous.name != current.name ||
          previous.phone != current.phone ||
          previous.imagePath != current.imagePath ||
          previous.subscriptionEndDate != current.subscriptionEndDate,
      builder: (context, state) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isDesktop ? 32.0 : 24.0),
              child: ConstrainedBox(
                constraints: isDesktop
                    ? const BoxConstraints(maxWidth: 800)
                    : const BoxConstraints(),
                child: Column(
                children: [
                  const SizedBox(height: 20),

                // صورة المستخدم
                Stack(
                  children: [
                    ProfileAvatar(imagePath: state.imagePath, onTap: _pickImage),
                    if (_isUploadingImage)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // بطاقة المعلومات
                _buildInfoCard(state),

                const SizedBox(height: 24),

                // زر تسجيل الخروج
                _buildLogoutButton(),
              ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء بطاقة المعلومات التي تحتوي على بيانات المستخدم
  /// تعرض الاسم، رقم الهاتف، والأيام المتبقية على الاشتراك
  Widget _buildInfoCard(UserState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الاسم
          ProfileInfoItem(
            icon: Icons.person_outline,
            label: 'الاسم',
            value: state.name,
          ),
          const SizedBox(height: 24),

          // رقم الهاتف
          ProfileInfoItem(
            icon: Icons.phone_outlined,
            label: 'رقم الهاتف',
            value: state.phone,
          ),
          const SizedBox(height: 24),

          // الأيام المتبقية على الاشتراك
          SubscriptionInfoCard(remainingDays: state.remainingDays),
        ],
      ),
    );
  }

  /// بناء زر تسجيل الخروج
  /// زر OutlinedButton مع تصميم مخصص
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _handleLogout,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          'تسجيل الخروج',
          style: AppStyles.mainTextStyle.copyWith(
            fontSize: 16,
            color: AppColors.primaryColor,
          ),
        ),
      ),
    );
  }
}
