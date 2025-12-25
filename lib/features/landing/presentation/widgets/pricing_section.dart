import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'section_container.dart';
import 'animated_wrapper.dart';

/// قسم الباقة
class PricingSection extends StatelessWidget {
  final bool isMobile;

  const PricingSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      isMobile: isMobile,
      gradientColors: [
        AppColors.primaryColor.withOpacity(0.08),
        AppColors.primaryColor.withOpacity(0.15),
        AppColors.primaryColor.withOpacity(0.08),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 48),
          _buildPricingCard(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'المميزات الشاملة',
          style: AppStyles.headingStyle.copyWith(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'كل ما تحتاجه لإدارة مجموعتك التعليمية في مكان واحد',
          style: AppStyles.textSecondaryStyle.copyWith(
            fontSize: isMobile ? 16 : 18,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPricingCard() {
    final features = [
      'إنشاء أكواد فريدة لكل طالب في مجموعتك',
      'إدارة كاملة للطلاب مع معلوماتهم وصورهم',
      'إنشاء كورسات متعددة مع تفاصيل كاملة',
      'رفع فيديوهات مباشرة إلى المنصة بجودة عالية',
      'إضافة مدة كل فيديو وتنظيمها بسهولة',
      'إنشاء اختبارات تفاعلية مع أسئلة متعددة',
      'تتبع تقدم الطلاب في الكورسات',
      'تنظيم كامل - كل مسؤول له طلابه وكورساته الخاصة',
      'لوحة تحكم سهلة الاستخدام',
      'إمكانية الوصول من أي جهاز (ويب، iOS، Android)',
    ];

    return Center(
      child: SizedBox(
        width: isMobile ? double.infinity : 600,
        child: AnimatedWrapper(
          duration: const Duration(milliseconds: 1000),
          beginScale: 0.9,
          endScale: 1.0,
          child: Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.secondaryColor,
                  AppColors.secondaryColor.withOpacity(0.98),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 3,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBadge(),
                const SizedBox(height: 24),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildPrice(),
                const SizedBox(height: 32),
                const Divider(thickness: 2),
                const SizedBox(height: 24),
                _buildFeaturesHeader(),
                const SizedBox(height: 20),
                ..._buildFeaturesList(features),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor,
              AppColors.primaryColor.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.star, color: AppColors.secondaryColor, size: 20),
            SizedBox(width: 8),
            Text(
              'الباقة المميزة',
              style: TextStyle(
                color: AppColors.secondaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Center(
      child: Text(
        'مميزات TeacherZone للمسؤولين',
        style: AppStyles.subHeadingStyle.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPrice() {
    return Center(
      child: Text(
        'منصة متكاملة',
        style: AppStyles.headingStyle.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildFeaturesHeader() {
    return Text(
      'المميزات الشاملة:',
      style: AppStyles.subHeadingStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  List<Widget> _buildFeaturesList(List<String> features) {
    return features.map((feature) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: AppColors.successColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                feature,
                style: AppStyles.textPrimaryStyle.copyWith(
                  fontSize: 16,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

