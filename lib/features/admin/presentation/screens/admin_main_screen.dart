import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:class_code/features/user/presentation/cubit/user_cubit.dart';
import 'package:class_code/features/user/presentation/cubit/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:html' as html if (dart.library.html) 'dart:html';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/bunny_storage_service.dart';
import '../../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../widgets/admin_app_bar.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  bool _isUploadingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AdminAppBar(
        title: 'لوحة الإدارة',
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة ترحيبية باسم الأدمن
          BlocBuilder<UserCubit, UserState>(
            builder: (context, userState) {
              if (userState.adminName != null &&
                  userState.adminName!.isNotEmpty) {
                return _buildWelcomeCard(
                  context,
                  userState.adminName!,
                  userState.adminPhone,
                  userState.adminDescription,
                  userState.adminImageUrl,
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(height: 16),
          // بطاقة إضافة الأكواد
          _buildAdminCard(
            context: context,
            title: 'إدارة الأكواد',
            description: 'إضافة وحذف الأكواد الخاصة بالطلاب',
            icon: Icons.vpn_key,
            color: AppColors.primaryColor,
            onTap: () {
              context.push(AppRouters.adminAddCodeScreen);
            },
          ),
          const SizedBox(height: 16),

          // بطاقة إضافة الكورسات
          _buildAdminCard(
            context: context,
            title: 'إدارة الكورسات',
            description: 'إضافة وتعديل وحذف الكورسات',
            icon: Icons.menu_book,
            color: AppColors.courseColor,
            onTap: () {
              context.push(AppRouters.adminAddCourseScreen);
            },
          ),
          const SizedBox(height: 16),

          // بطاقة إدارة فيديوهات الكورسات
          _buildAdminCard(
            context: context,
            title: 'إدارة الفيديوهات',
            description: 'إضافة الفيديوهات للكورسات المختلفة',
            icon: Icons.video_library,
            color: AppColors.accentColor,
            onTap: () {
              context.push(AppRouters.adminManageVideosScreen);
            },
          ),
          const SizedBox(height: 16),

          // بطاقة إدارة الاختبارات
          _buildAdminCard(
            context: context,
            title: 'إدارة الاختبارات',
            description: 'إضافة الاختبارات والأسئلة',
            icon: Icons.quiz,
            color: AppColors.examColor,
            onTap: () {
              context.push(AppRouters.adminAddTestScreen);
            },
          ),
        ],
      ),
    );
  }

  /// بناء بطاقة ترحيبية باسم الأدمن
  Widget _buildWelcomeCard(
    BuildContext context,
    String adminName,
    String? adminPhone,
    String? adminDescription,
    String? adminImageUrl,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryDark,
            AppColors.primaryColor.withOpacity(0.9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الصف العلوي: الصورة/الأيقونة والترحيب وأيقونة تسجيل الخروج
            Row(
              children: [
                // صورة أو أيقونة ترحيبية
                GestureDetector(
                  onTap: () => _pickAndUploadAdminImage(context),
                  child: Stack(
                    children: [
            Container(
                        width: 70,
                        height: 70,
              decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondaryColor.withOpacity(0.3),
                              AppColors.secondaryColor.withOpacity(0.2),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                color: AppColors.secondaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondaryColor.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: adminImageUrl != null && adminImageUrl.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  adminImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.person,
                                      color: AppColors.secondaryColor,
                                      size: 36,
                                    );
                                  },
                                ),
                              )
                            : const Icon(
                Icons.person,
                color: AppColors.secondaryColor,
                                size: 36,
                              ),
                      ),
                      // أيقونة إضافة/تعديل الصورة
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 2,
                            ),
                          ),
                          child: _isUploadingImage
                              ? const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryColor,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Icons.camera_alt,
                                  color: AppColors.primaryColor,
                                  size: 14,
                                ),
                        ),
                      ),
                    ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                        'مرحباً بك',
                    style: AppStyles.textSecondaryStyle.copyWith(
                          color: AppColors.secondaryColor.withOpacity(0.9),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adminName,
                    style: AppStyles.subHeadingStyle.copyWith(
                      color: AppColors.secondaryColor,
                          fontSize: 22,
                      fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // أيقونة تسجيل الخروج
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _handleLogout(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.secondaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: AppColors.secondaryColor,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // معلومات إضافية (رقم الهاتف والوصف)
            if ((adminPhone != null && adminPhone.isNotEmpty) ||
                (adminDescription != null && adminDescription.isNotEmpty)) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.secondaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (adminPhone != null && adminPhone.isNotEmpty) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.phone_rounded,
                              size: 18,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'رقم الهاتف',
                                  style: AppStyles.textSecondaryStyle.copyWith(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  adminPhone,
                                  style: AppStyles.textSecondaryStyle.copyWith(
                                    color: AppColors.secondaryColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (adminPhone != null &&
                        adminPhone.isNotEmpty &&
                        adminDescription != null &&
                        adminDescription.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.secondaryColor,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (adminDescription != null &&
                        adminDescription.isNotEmpty) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              size: 18,
                              color: AppColors.secondaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الوصف',
                                  style: AppStyles.textSecondaryStyle.copyWith(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.7,
                                    ),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  adminDescription,
                                  style: AppStyles.textSecondaryStyle.copyWith(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.9,
                                    ),
                                    fontSize: 14,
                                    height: 1.5,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // الأيقونة
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                const SizedBox(width: 16),
                // العنوان والوصف
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppStyles.textSecondaryStyle.copyWith(
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                // سهم الانتقال
                Icon(
                  Icons.arrow_back_ios,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// اختيار ورفع صورة الأدمن
  Future<void> _pickAndUploadAdminImage(BuildContext context) async {
    final userCubit = context.read<UserCubit>();
    final userState = userCubit.state;
    final adminCode = userState.adminCode;

    if (adminCode == null || adminCode.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن رفع الصورة: كود الأدمن غير موجود'),
            backgroundColor: AppColors.errorColor,
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

        html.document.body!.append(input);

        final completer = Completer<html.File?>();

        input.onChange.listen((event) {
          final files = input.files;
          if (files != null && files.isNotEmpty) {
            completer.complete(files.first);
          } else {
            completer.complete(null);
          }
          input.remove();
        });

        input.click();

        final htmlFile = await completer.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            input.remove();
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

        // إنشاء اسم ملف فريد في مجلد admin
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        // تنظيف اسم الملف من الأحرف غير المسموحة
        final originalExtension = htmlFile.name.split('.').last.toLowerCase();
        final extension = originalExtension.isEmpty ? 'jpg' : originalExtension;
        // تنظيف adminCode من الأحرف غير المسموحة
        final cleanAdminCode = adminCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
        fileName = 'admin/admin_${cleanAdminCode}_$timestamp.$extension';

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
        // للـ iOS و Android: استخدام file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (!mounted) return;

        if (result == null || result.files.isEmpty) {
          setState(() {
            _isUploadingImage = false;
          });
          return;
        }

        final selectedFile = result.files.first;

        if (selectedFile.path != null && selectedFile.path!.isNotEmpty) {
          final file = File(selectedFile.path!);
          if (await file.exists()) {
            imageBytes = await file.readAsBytes();
            // إنشاء اسم ملف فريد في مجلد admin
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final extension = (selectedFile.extension ?? 'jpg').replaceFirst('.', '').toLowerCase();
            // تنظيف adminCode من الأحرف غير المسموحة
            final cleanAdminCode = adminCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
            fileName = 'admin/admin_${cleanAdminCode}_$timestamp.$extension';
          } else {
            setState(() {
              _isUploadingImage = false;
            });
            return;
          }
        } else if (selectedFile.bytes != null) {
          imageBytes = selectedFile.bytes;
          // إنشاء اسم ملف فريد في مجلد admin
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final extension = (selectedFile.extension ?? 'jpg').replaceFirst('.', '').toLowerCase();
          // تنظيف adminCode من الأحرف غير المسموحة
          final cleanAdminCode = adminCode.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
          fileName = 'admin/admin_${cleanAdminCode}_$timestamp.$extension';
        } else {
          setState(() {
            _isUploadingImage = false;
          });
          return;
        }
      }

      if (imageBytes == null) {
        setState(() {
          _isUploadingImage = false;
        });
        return;
      }

      // رفع الصورة إلى Bunny Storage
      final imageUrl = await BunnyStorageService.uploadImage(
        imageBytes: imageBytes,
        fileName: fileName,
      );

      // تحديث Firestore
      await InjectionContainer.adminRepo.updateAdminCodeImageUrl(
        adminCode,
        imageUrl,
      );

      // تحديث UserCubit
      await userCubit.updateUser(adminImageUrl: imageUrl);

      if (mounted) {
        // إعادة بناء الواجهة لعرض الصورة
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفع الصورة بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      debugPrint('خطأ في رفع صورة الأدمن: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفع الصورة: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
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
  }

  /// معالجة تسجيل الخروج
  /// يقوم بمسح بيانات المستخدم وإعادة التوجيه لصفحة تسجيل الدخول
  Future<void> _handleLogout(BuildContext context) async {
    // عرض تأكيد قبل تسجيل الخروج
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد تسجيل الخروج', style: AppStyles.subHeadingStyle),
        content: Text(
          'هل أنت متأكد من رغبتك في تسجيل الخروج؟',
          style: AppStyles.textSecondaryStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'إلغاء',
              style: AppStyles.textSecondaryStyle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'تسجيل الخروج',
              style: AppStyles.textSecondaryStyle.copyWith(
                color: AppColors.errorColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      // مسح بيانات المستخدم
      final userCubit = context.read<UserCubit>();
      final userCode = userCubit.state.code;

      // إزالة ربط الجهاز من الكود في Firestore (إذا كان هناك كود)
      if (userCode != null && userCode.isNotEmpty) {
        try {
          final authDataSource =
              InjectionContainer.authRemoteDataSource as dynamic;
          if (authDataSource is AuthRemoteDataSourceImpl) {
            await authDataSource.logoutWithCode(userCode);
          }
        } catch (e) {
          debugPrint('❌ خطأ في إزالة ربط الجهاز: $e');
          // نستمر في تسجيل الخروج حتى لو فشل تحديث deviceId
        }
      }

      await userCubit.clearUserData();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الخروج'),
            backgroundColor: AppColors.successColor,
          ),
        );
        // إعادة التوجيه لصفحة تسجيل الدخول
        context.go(AppRouters.codeInputScreen);
      }
    }
  }
}
