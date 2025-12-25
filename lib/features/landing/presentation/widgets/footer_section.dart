import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'animated_wrapper.dart';

/// Footer للـ Landing Page
class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.9),
            AppColors.primaryColor.withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            AnimatedWrapper(
              duration: const Duration(milliseconds: 1000),
              beginScale: 0.8,
              endScale: 1.0,
              child: Text(
                'TeacherZone',
                style: AppStyles.headingStyle.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 TeacherZone. جميع الحقوق محفوظة.',
              style: AppStyles.textPrimaryStyle.copyWith(
                color: AppColors.secondaryColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

