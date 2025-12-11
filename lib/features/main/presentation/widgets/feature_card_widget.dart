import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class FeatureCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback? onTap;

  const FeatureCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                _FeatureIcon(icon: icon),
                const SizedBox(width: 16),
                Expanded(
                  child: _FeatureContent(
                    title: title,
                    description: description,
                  ),
                ),
                const _ArrowIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;

  const _FeatureIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: AppColors.primaryColor, size: 28),
    );
  }
}

class _FeatureContent extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureContent({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppStyles.subHeadingStyle.copyWith(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          description,
          style: AppStyles.textSecondaryStyle.copyWith(fontSize: 13),
        ),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  const _ArrowIcon();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.arrow_forward_ios,
      size: 16,
      color: AppColors.textSecondary,
    );
  }
}
