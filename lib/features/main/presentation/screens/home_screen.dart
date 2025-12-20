import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../widgets/user_card_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/feature_card_widget.dart';
import '../widgets/welcome_section_widget.dart';

/// الشاشة الرئيسية للتطبيق
/// تعرض معلومات المستخدم، إحصائيات سريعة، وميزات المنصة
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
              _buildUserCard(),
              const SizedBox(height: 24),

              // قسم تعريف عن المحتوى
              const WelcomeSectionWidget(),
              const SizedBox(height: 24),

              // إحصائيات سريعة
              _buildStatsSection(),
              const SizedBox(height: 24),

              // قسم الميزات
              _buildFeaturesSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء بطاقة المستخدم
  /// تعرض معلومات المستخدم (الاسم، رقم الهاتف، الصورة، الأيام المتبقية)
  /// تستخدم BlocBuilder للتحديث التلقائي عند تغيير بيانات المستخدم
  Widget _buildUserCard() {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) =>
          previous.name != current.name ||
          previous.phone != current.phone ||
          previous.imagePath != current.imagePath ||
          previous.subscriptionEndDate != current.subscriptionEndDate,
      builder: (context, state) {
        return UserCardWidget(state: state);
      },
    );
  }

  /// بناء قسم الإحصائيات
  /// يعرض ثلاثة بطاقات إحصائية: الدروس المكتملة، الكورسات النشطة، الاختبارات
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

  /// بناء قسم الميزات
  /// يعرض قائمة بالميزات المتاحة في المنصة (دروس فيديو، اختبارات، تتبع التقدم)
  Widget _buildFeaturesSection() {
    // بيانات الميزات - يمكن تحويلها إلى Cubit في المستقبل
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Text(
          'مميزات المنصة',
          style: AppStyles.headingStyle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        // قائمة الميزات
        ...features.map((feature) {
          return FeatureCardWidget(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
          );
        }).toList(),
      ],
    );
  }
}
