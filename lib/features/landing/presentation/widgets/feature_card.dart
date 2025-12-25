import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'animated_wrapper.dart';

/// بطاقة ميزة قابلة لإعادة الاستخدام
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedWrapper(
      duration: const Duration(milliseconds: 600),
      beginScale: 0.8,
      endScale: 1.0,
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryColor,
              AppColors.secondaryColor.withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildIcon(),
            const SizedBox(height: 24),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.2),
            AppColors.primaryColor.withOpacity(0.1),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: 40, color: AppColors.primaryColor),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: AppStyles.subHeadingStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      description,
      style: AppStyles.textSecondaryStyle.copyWith(
        fontSize: 14,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

