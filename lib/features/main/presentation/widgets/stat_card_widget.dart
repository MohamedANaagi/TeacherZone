import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class StatCardWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const StatCardWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
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
            _StatIcon(icon: icon, color: color),
            const SizedBox(height: 12),
            _StatTitle(title: title, color: color),
            const SizedBox(height: 4),
            _StatSubtitle(subtitle: subtitle),
          ],
        ),
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _StatIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}

class _StatTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _StatTitle({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppStyles.headingStyle.copyWith(fontSize: 24, color: color),
    );
  }
}

class _StatSubtitle extends StatelessWidget {
  final String subtitle;

  const _StatSubtitle({required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: AppStyles.textSecondaryStyle.copyWith(fontSize: 12),
      textAlign: TextAlign.center,
    );
  }
}
