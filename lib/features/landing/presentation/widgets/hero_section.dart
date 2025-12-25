import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import 'animated_wrapper.dart';

/// Hero Section للـ Landing Page
class HeroSection extends StatelessWidget {
  final bool isMobile;

  const HeroSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 60 : 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.9),
            AppColors.primaryColor.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 32),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildSubtitle(),
            const SizedBox(height: 40),
            _buildCtaButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return AnimatedWrapper(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      beginScale: 0.0,
      endScale: 1.0,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryColor,
              AppColors.secondaryColor.withOpacity(0.9),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryColor.withOpacity(0.5),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: const Icon(
          Icons.school,
          size: 60,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      'TeacherZone',
      style: AppStyles.headingStyle.copyWith(
        fontSize: isMobile ? 32 : 48,
        fontWeight: FontWeight.bold,
        color: AppColors.secondaryColor,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    return Column(
      children: [
        Text(
          'منصة إدارة تعليمية متكاملة لإدارة طلابك وكورساتك بسهولة',
          style: AppStyles.textPrimaryStyle.copyWith(
            fontSize: isMobile ? 16 : 20,
            color: AppColors.secondaryColor.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'أنت المسؤول - أنشئ أكواد للطلاب، أضف الكورسات والفيديوهات، ونظم كل شيء',
          style: AppStyles.textPrimaryStyle.copyWith(
            fontSize: isMobile ? 14 : 16,
            color: AppColors.secondaryColor.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCtaButton(BuildContext context) {
    return AnimatedWrapper(
      duration: const Duration(milliseconds: 1200),
      translateOffset: const Offset(0, 20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondaryColor,
              AppColors.secondaryColor.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryColor.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => context.push(AppRouters.codeInputScreen),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'ابدأ الآن',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
              SizedBox(width: 12),
              Icon(
                Icons.arrow_forward,
                size: 24,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

