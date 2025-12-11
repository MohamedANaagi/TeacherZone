import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class WelcomeSectionWidget extends StatelessWidget {
  const WelcomeSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WelcomeHeader(),
            const SizedBox(height: 20),
            _WelcomeDescription(),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
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
                style: AppStyles.textSecondaryStyle.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeDescription extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'استمتع بتجربة تعليمية متكاملة مع دروس فيديو عالية الجودة، محتوى منظم، واختبارات تفاعلية لمساعدتك في تحقيق أهدافك التعليمية.',
      style: AppStyles.textPrimaryStyle.copyWith(
        fontSize: 15,
        height: 1.6,
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.right,
    );
  }
}
