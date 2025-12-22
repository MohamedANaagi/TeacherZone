import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/services/image_storage_service.dart';
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

  /// اختيار صورة من المعرض وحفظها محلياً في الجهاز
  ///
  /// الخطوات:
  /// 1. فتح معرض الصور باستخدام ImagePicker
  /// 2. حفظ الصورة محلياً في مجلد التطبيق بناءً على الكود
  /// 3. تحديث imagePath في UserCubit بمسار الصورة المحلي
  /// 4. في حالة حدوث خطأ، عرض رسالة خطأ للمستخدم
  Future<void> _pickImage() async {
    try {
      final userCubit = context.read<UserCubit>();
      final userCode = userCubit.state.code;

      if (userCode == null || userCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('لا يمكن حفظ الصورة: الكود غير موجود'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        try {
          // حفظ الصورة محلياً بناءً على الكود
          final savedPath = await ImageStorageService.saveProfileImage(
            sourcePath: image.path,
            code: userCode,
          );

          // تحديث مسار الصورة في UserCubit
          await userCubit.updateUser(imagePath: savedPath);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم حفظ الصورة بنجاح'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (saveError) {
          if (mounted) {
            // استخراج رسالة الخطأ
            String errorMessage = 'فشل حفظ الصورة';
            if (saveError is Exception) {
              errorMessage = saveError.toString().replaceFirst('Exception: ', '');
            } else {
              errorMessage = saveError.toString();
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
          
          debugPrint('خطأ حفظ الصورة: $saveError');
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                // صورة المستخدم
                ProfileAvatar(imagePath: state.imagePath, onTap: _pickImage),

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
