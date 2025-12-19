import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
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
        ],
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
}
