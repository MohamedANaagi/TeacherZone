import 'package:flutter/material.dart';
import 'package:class_code/core/router/app_routers.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_content.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      "title": "مرحبًا في TeacherZone",
      "subtitle": "منصتك لمتابعة دروس المدرّس في مكان واحد، بسهولة وتنظيم.",
    },
    {
      "title": "محتوى تعليمي منظم",
      "subtitle":
          "دروس فيديو مرتّبة بالترتيب الصحيح، مع شرح واضح و تركيز على أهم النقاط.",
    },
    {
      "title": "الدخول بالكود",
      "subtitle":
          "المدرّس يقدّم لك كود خاص، تدخله وتفتح كل محتوى الكورس المتاح لك.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Column(
          children: [
            // زرار تخطي
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.go(AppRouters.codeInputScreen);
                },
                child: Text(
                  'تخطي',
                  style: AppStyles.grey12MediumStyle.copyWith(fontSize: 14),
                ),
              ),
            ),

            // PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (_, index) {
                  final page = pages[index];

                  return OnboardingContent(
                    icon: index == 0
                        ? Icons.school
                        : index == 1
                        ? Icons.play_circle_fill
                        : Icons.lock_open,
                    title: page["title"]!,
                    subtitle: page["subtitle"]!,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentIndex == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.primaryColor
                        : AppColors.textSecondary.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // زرار التالي/ابدأ الآن
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: OnboardingButton(
                isLastPage: currentIndex == pages.length - 1,
                onPressed: () {
                  if (currentIndex == pages.length - 1) {
                    context.go(AppRouters.codeInputScreen);
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
