import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'animated_wrapper.dart';

/// بطاقة جهاز قابلة لإعادة الاستخدام
class DeviceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const DeviceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedWrapper(
      duration: const Duration(milliseconds: 800),
      translateOffset: const Offset(0, 30),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildIcon(),
            const SizedBox(height: 20),
            _buildTitle(),
            const SizedBox(height: 8),
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
          colors: [color, color.withOpacity(0.7)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Icon(icon, size: 40, color: AppColors.secondaryColor),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: AppStyles.subHeadingStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color,
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

