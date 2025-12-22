import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_routers.dart';

import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/services/onboarding_service.dart';
import '../widgets/onboarding_button.dart';
import '../widgets/onboarding_content.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int currentIndex = 0;
  
  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

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
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  void _onPageChanged(int index) {
    setState(() => currentIndex = index);
    // إعادة تشغيل animations عند تغيير الصفحة
    _fadeController.reset();
    _slideController.reset();
    _scaleController.reset();
    _startAnimations();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondaryColor,
              AppColors.backgroundLight,
              AppColors.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // زرار تخطي مع animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: () async {
                        await OnboardingService.setOnboardingCompleted();
                        if (mounted) {
                          context.go(AppRouters.codeInputScreen);
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: Text(
                        'تخطي',
                        style: AppStyles.grey12MediumStyle.copyWith(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // PageView مع animations
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (_, index) {
                    final page = pages[index];

                    return SlideTransition(
                      position: _slideAnimation,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: OnboardingContent(
                            icon: index == 0
                                ? Icons.school
                                : index == 1
                                    ? Icons.play_circle_fill
                                    : Icons.lock_open,
                            title: page["title"]!,
                            subtitle: page["subtitle"]!,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

            // Dots مع animation محسّن
            FadeTransition(
              opacity: _fadeAnimation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => GestureDetector(
                    onTap: () {
                      _pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: currentIndex == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: currentIndex == index
                            ? AppColors.primaryColor
                            : AppColors.textSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: currentIndex == index
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryColor.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // زرار التالي/ابدأ الآن مع animation
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: OnboardingButton(
                    isLastPage: currentIndex == pages.length - 1,
                    onPressed: () async {
                      if (currentIndex == pages.length - 1) {
                        await OnboardingService.setOnboardingCompleted();
                        if (mounted) {
                          context.go(AppRouters.codeInputScreen);
                        }
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                ),
              ),
            ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
