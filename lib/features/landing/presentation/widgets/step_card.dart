import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'animated_wrapper.dart';

/// بطاقة خطوة قابلة لإعادة الاستخدام
class StepCard extends StatelessWidget {
  final int stepNumber;
  final IconData icon;
  final String title;
  final String description;
  final bool isMobile;

  const StepCard({
    super.key,
    required this.stepNumber,
    required this.icon,
    required this.title,
    required this.description,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedWrapper(
      duration: Duration(milliseconds: 600 + (stepNumber * 100)),
      translateOffset: const Offset(0, 40),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
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
          border: Border.all(
            color: AppColors.primaryColor.withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStepNumber(),
            const SizedBox(height: 16),
            _buildIcon(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 12),
            _buildDescription(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepNumber() {
    return Container(
      width: isMobile ? 50 : 60,
      height: isMobile ? 50 : 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '$stepNumber',
          style: AppStyles.headingStyle.copyWith(
            fontSize: isMobile ? 24 : 28,
            fontWeight: FontWeight.bold,
            color: AppColors.secondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: isMobile ? 60 : 80,
      height: isMobile ? 60 : 80,
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
            color: AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: isMobile ? 30 : 40,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: AppStyles.subHeadingStyle.copyWith(
        fontSize: isMobile ? 18 : 20,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return Text(
      description,
      style: AppStyles.textSecondaryStyle.copyWith(
        fontSize: isMobile ? 13 : 14,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }
}

