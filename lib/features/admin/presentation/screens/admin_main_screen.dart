import 'package:class_code/features/user/presentation/cubit/user_cubit.dart';
import 'package:class_code/features/user/presentation/cubit/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../widgets/admin_app_bar.dart';

class AdminMainScreen extends StatelessWidget {
  const AdminMainScreen({super.key});

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
              if (userState.adminName != null && userState.adminName!.isNotEmpty) {
                return _buildWelcomeCard(context, userState.adminName!);
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
          const SizedBox(height: 32),

          // زر تسجيل الخروج
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  /// بناء بطاقة ترحيبية باسم الأدمن
  Widget _buildWelcomeCard(BuildContext context, String adminName) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // أيقونة ترحيبية
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.secondaryColor,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            // النص الترحيبي
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً',
                    style: AppStyles.textSecondaryStyle.copyWith(
                      color: AppColors.secondaryColor.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    adminName,
                    style: AppStyles.subHeadingStyle.copyWith(
                      color: AppColors.secondaryColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
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

  /// بناء زر تسجيل الخروج
  /// يقوم بمسح بيانات المستخدم وإعادة التوجيه لصفحة تسجيل الدخول
  Widget _buildLogoutButton(BuildContext context) {
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
          onTap: () => _handleLogout(context),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, color: AppColors.errorColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  'تسجيل الخروج',
                  style: AppStyles.subHeadingStyle.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          final authDataSource = InjectionContainer.authRemoteDataSource as dynamic;
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
