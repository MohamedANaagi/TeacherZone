

import 'package:flutter/material.dart';
import '../../../core/styling/app_color.dart';
import '../../../core/styling/app_styles.dart';

class OnboardingContent extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const OnboardingContent({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 16,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              icon,
              size: 60,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppStyles.mainTextStyle.copyWith(
              color: AppColors.primaryColor,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppStyles.black16w500Style.copyWith(
              color: AppColors.greyColor,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
