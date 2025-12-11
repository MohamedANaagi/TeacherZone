import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/cubit/user_cubit.dart';
import '../../../../../core/cubit/user_state.dart';
import '../widgets/user_card_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/feature_card_widget.dart';
import '../widgets/welcome_section_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة المستخدم في الأعلى
              BlocBuilder<UserCubit, UserState>(
                buildWhen: (previous, current) =>
                    previous.name != current.name ||
                    previous.email != current.email ||
                    previous.imagePath != current.imagePath ||
                    previous.subscriptionEndDate != current.subscriptionEndDate,
                builder: (context, state) {
                  return UserCardWidget(state: state);
                },
              ),
              const SizedBox(height: 24),

              // قسم تعريف عن المحتوى
              const WelcomeSectionWidget(),
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
      ),
    );
  }

  /// قسم الإحصائيات
  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: StatCardWidget(
            icon: Icons.play_circle_filled,
            title: '12',
            subtitle: 'درس مكتمل',
            color: AppColors.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCardWidget(
            icon: Icons.book,
            title: '3',
            subtitle: 'كورسات نشطة',
            color: AppColors.infoColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCardWidget(
            icon: Icons.quiz,
            title: '8',
            subtitle: 'اختبارات',
            color: AppColors.accentColor,
          ),
        ),
      ],
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
        return FeatureCardWidget(
          icon: feature['icon'] as IconData,
          title: feature['title'] as String,
          description: feature['description'] as String,
        );
      }).toList(),
    );
  }
}
