import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'section_container.dart';
import 'step_card.dart';

/// قسم شرح الاستخدام
class HowToUseSection extends StatelessWidget {
  final bool isMobile;

  const HowToUseSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      isMobile: isMobile,
      gradientColors: [
        AppColors.backgroundLight,
        AppColors.backgroundColor,
        AppColors.backgroundLight,
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 48),
          _buildSteps(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'كيفية الاستخدام',
      style: AppStyles.headingStyle.copyWith(
        fontSize: isMobile ? 28 : 36,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSteps() {
    final steps = [
      {
        'number': 1,
        'icon': Icons.admin_panel_settings,
        'title': 'سجل دخول كمسؤول',
        'description':
            'سجل دخولك باستخدام كود المسؤول الخاص بك للوصول إلى لوحة التحكم',
      },
      {
        'number': 2,
        'icon': Icons.person_add_alt_1,
        'title': 'أنشئ أكواد للطلاب',
        'description':
            'قم بإنشاء أكواد فريدة لكل طالب في مجموعتك. كل كود مرتبط بك كمسؤول',
      },
      {
        'number': 3,
        'icon': Icons.add_circle_outline,
        'title': 'أضف الكورسات',
        'description':
            'أنشئ كورسات جديدة مع إضافة العنوان، الوصف، المدرب، والمدة. كل كورس مرتبط بك',
      },
      {
        'number': 4,
        'icon': Icons.video_file,
        'title': 'ارفع الفيديوهات',
        'description':
            'ارفع فيديوهات تعليمية مباشرة إلى كل كورس. يمكنك إضافة مدة الفيديو وتنظيمها',
      },
      {
        'number': 5,
        'icon': Icons.quiz,
        'title': 'أنشئ الاختبارات',
        'description':
            'صمم اختبارات تفاعلية مع أسئلة متعددة الخيارات لتقييم أداء طلابك',
      },
    ];

    if (isMobile) {
      return Column(
        children: steps
            .map((step) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: StepCard(
                    stepNumber: step['number'] as int,
                    icon: step['icon'] as IconData,
                    title: step['title'] as String,
                    description: step['description'] as String,
                    isMobile: true,
                  ),
                ))
            .toList(),
      );
    }

    // Desktop layout: 2 columns for steps 1-4, centered for step 5
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StepCard(
                stepNumber: steps[0]['number'] as int,
                icon: steps[0]['icon'] as IconData,
                title: steps[0]['title'] as String,
                description: steps[0]['description'] as String,
                isMobile: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StepCard(
                stepNumber: steps[1]['number'] as int,
                icon: steps[1]['icon'] as IconData,
                title: steps[1]['title'] as String,
                description: steps[1]['description'] as String,
                isMobile: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: StepCard(
                stepNumber: steps[2]['number'] as int,
                icon: steps[2]['icon'] as IconData,
                title: steps[2]['title'] as String,
                description: steps[2]['description'] as String,
                isMobile: false,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: StepCard(
                stepNumber: steps[3]['number'] as int,
                icon: steps[3]['icon'] as IconData,
                title: steps[3]['title'] as String,
                description: steps[3]['description'] as String,
                isMobile: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Center(
          child: SizedBox(
            width: 400,
            child: StepCard(
              stepNumber: steps[4]['number'] as int,
              icon: steps[4]['icon'] as IconData,
              title: steps[4]['title'] as String,
              description: steps[4]['description'] as String,
              isMobile: false,
            ),
          ),
        ),
      ],
    );
  }
}

