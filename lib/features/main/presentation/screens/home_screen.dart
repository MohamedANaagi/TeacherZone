import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/cubit/user_cubit.dart';
import '../../../../../core/cubit/user_state.dart';
import 'dart:io';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة المستخدم في الأعلى
            BlocBuilder<UserCubit, UserState>(
              builder: (context, state) {
                return _buildUserCard(state);
              },
            ),
            const SizedBox(height: 24),

            // قسم تعريف عن المحتوى
            _buildWelcomeSection(),
            const SizedBox(height: 24),

            // إحصائيات سريعة
            _buildStatsSection(),
            const SizedBox(height: 24),

            // قسم الميزات
            Text(
              'مميزات المنصة',
              style: AppStyles.headingStyle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 16),
            _buildFeaturesSection(),
          ],
        ),
      ),
    );
  }

  /// بطاقة المستخدم في الأعلى
  Widget _buildUserCard(UserState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryColor, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة المستخدم
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.secondaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondaryColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: state.imagePath != null
                  ? Image.file(
                      File(state.imagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultAvatar();
                      },
                    )
                  : _buildDefaultAvatar(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك مجدداً!',
                  style: AppStyles.subTextStyle.copyWith(
                    color: AppColors.secondaryColor.withValues(alpha: 0.9),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.name ?? 'المستخدم',
                  style: AppStyles.mainTextStyle.copyWith(
                    color: AppColors.secondaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    state.email!,
                    style: AppStyles.subTextStyle.copyWith(
                      color: AppColors.secondaryColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
                if (state.remainingDays > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: AppColors.secondaryColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${state.remainingDays} يوم متبقي',
                          style: AppStyles.subTextStyle.copyWith(
                            color: AppColors.secondaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// قسم الترحيب والتعريف
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك في TeacherZone',
                      style: AppStyles.headingStyle.copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'منصتك التعليمية المفضلة',
                      style: AppStyles.textSecondaryStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'استمتع بتجربة تعليمية متكاملة مع دروس فيديو عالية الجودة، محتوى منظم، واختبارات تفاعلية لمساعدتك في تحقيق أهدافك التعليمية.',
            style: AppStyles.textPrimaryStyle.copyWith(
              fontSize: 15,
              height: 1.6,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  /// قسم الإحصائيات
  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.play_circle_filled,
            title: '12',
            subtitle: 'درس مكتمل',
            color: AppColors.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.book,
            title: '3',
            subtitle: 'كورسات نشطة',
            color: AppColors.infoColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.quiz,
            title: '8',
            subtitle: 'اختبارات',
            color: AppColors.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppStyles.headingStyle.copyWith(fontSize: 24, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AppStyles.textSecondaryStyle.copyWith(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.secondaryColor.withValues(alpha: 0.2),
      child: Icon(Icons.person, size: 35, color: AppColors.secondaryColor),
    );
  }

  /// قسم الميزات
  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.video_library,
        'title': 'دروس فيديو',
        'description': 'محتوى تعليمي عالي الجودة',
      },
      {
        'icon': Icons.quiz,
        'title': 'اختبارات تفاعلية',
        'description': 'اختبر معلوماتك بسهولة',
      },
      {
        'icon': Icons.track_changes,
        'title': 'تتبع التقدم',
        'description': 'راقب تقدمك في التعلم',
      },
    ];

    return Column(
      children: features.map((feature) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature['icon'] as IconData,
                  color: AppColors.primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature['title'] as String,
                      style: AppStyles.subHeadingStyle.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature['description'] as String,
                      style: AppStyles.textSecondaryStyle.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
