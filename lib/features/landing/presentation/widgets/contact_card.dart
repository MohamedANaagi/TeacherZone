import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'animated_wrapper.dart';

/// بطاقة تواصل قابلة لإعادة الاستخدام
class ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const ContactCard({
    super.key,
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedWrapper(
      duration: const Duration(milliseconds: 800),
      beginScale: 0.9,
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
            _buildIcon(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 8),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 60,
      height: 60,
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
      child: Icon(icon, size: 30, color: AppColors.primaryColor),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: AppStyles.subHeadingStyle.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContent() {
    return Text(
      content,
      style: AppStyles.textSecondaryStyle.copyWith(fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}

