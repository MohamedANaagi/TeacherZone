import 'package:flutter/material.dart';
import '../../../../../core/styling/app_styles.dart';
import 'section_container.dart';
import 'feature_card.dart';

/// قسم معلومات عن المنصة
class AboutSection extends StatelessWidget {
  final bool isMobile;

  const AboutSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 48),
          _buildFeaturesGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'لماذا TeacherZone؟',
          style: AppStyles.headingStyle.copyWith(
            fontSize: isMobile ? 28 : 36,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'منصة شاملة لإدارة مجموعتك التعليمية بكل سهولة واحترافية',
          style: AppStyles.textSecondaryStyle.copyWith(
            fontSize: isMobile ? 14 : 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'icon': Icons.people,
        'title': 'إدارة الطلاب',
        'description': 'أنشئ أكواد فريدة لكل طالب وادفع مجموعتك بسهولة',
      },
      {
        'icon': Icons.menu_book,
        'title': 'إدارة الكورسات',
        'description': 'أنشئ كورسات متخصصة ونظمها حسب احتياجاتك',
      },
      {
        'icon': Icons.video_library,
        'title': 'رفع الفيديوهات',
        'description': 'ارفع فيديوهات تعليمية عالية الجودة مباشرة إلى المنصة',
      },
      {
        'icon': Icons.quiz,
        'title': 'إنشاء الاختبارات',
        'description': 'صمم اختبارات تفاعلية لتقييم أداء طلابك',
      },
    ];

    if (isMobile) {
      return Column(
        children: features
            .map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: FeatureCard(
                    icon: feature['icon'] as IconData,
                    title: feature['title'] as String,
                    description: feature['description'] as String,
                  ),
                ))
            .toList(),
      );
    }

    return Row(
      children: features
          .map((feature) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: FeatureCard(
                    icon: feature['icon'] as IconData,
                    title: feature['title'] as String,
                    description: feature['description'] as String,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

