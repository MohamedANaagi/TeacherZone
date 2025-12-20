import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

/// Widget لعرض معلومات الاشتراك (الأيام المتبقية)
/// يعرض عدد الأيام المتبقية على الاشتراك بشكل بارز
class SubscriptionInfoCard extends StatelessWidget {
  /// عدد الأيام المتبقية على الاشتراك
  final int remainingDays;

  const SubscriptionInfoCard({super.key, required this.remainingDays});

  @override
  Widget build(BuildContext context) {
    final hasActiveSubscription = remainingDays > 0;
    final displayText = hasActiveSubscription
        ? '$remainingDays يوم'
        : 'لا يوجد اشتراك نشط';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: AppColors.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الأيام المتبقية على الاشتراك',
                  style: AppStyles.grey12MediumStyle.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: AppStyles.mainTextStyle.copyWith(
                    fontSize: 20,
                    color: hasActiveSubscription
                        ? AppColors.primaryColor
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
