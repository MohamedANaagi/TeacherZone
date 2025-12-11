import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../../../core/services/onboarding_service.dart';
import '../../../../../core/cubit/user_cubit.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();

    // Main Animation Controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Pulse Animation Controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Particle Animation Controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Scale Animation
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Fade Animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    // Rotation Animation
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Pulse Animation
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Particle Animation
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // Start main animation
    _mainController.forward();

    // تحميل بيانات المستخدم ثم الانتقال
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // انتظار تحميل البيانات
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    final userCubit = context.read<UserCubit>();
    await userCubit.loadUserData();

    // بعد 3.5 ثانية من بدء التطبيق، التحقق من حالة تسجيل الدخول
    await Future.delayed(const Duration(milliseconds: 3400));
    if (!mounted) return;

    final isLoggedIn = userCubit.state.isLoggedIn;
    debugPrint('حالة تسجيل الدخول في Splash: $isLoggedIn');

    if (isLoggedIn) {
      // إذا كان المستخدم مسجل دخول، الانتقال للشاشة الرئيسية
      if (mounted) {
        context.go(AppRouters.mainScreen);
      }
      return;
    }

    // التحقق من إذا كان تم عرض الـ Onboarding من قبل
    final isCompleted = await OnboardingService.isOnboardingCompleted();

    if (isCompleted) {
      // إذا تم عرضها من قبل، الانتقال مباشرة لشاشة تسجيل الدخول
      if (mounted) {
        context.go(AppRouters.codeInputScreen);
      }
    } else {
      // إذا لم يتم عرضها، الانتقال لشاشة الـ Onboarding
      if (mounted) {
        context.go(AppRouters.onBoardingScreen);
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Stack(
        children: [
          // Animated Background Circles
          ...List.generate(5, (index) => _buildAnimatedCircle(index)),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon with rotation
                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.secondaryColor.withValues(
                            alpha: 0.2,
                          ),
                          border: Border.all(
                            color: AppColors.secondaryColor,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.school,
                          size: 60,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Text with multiple animations
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Text(
                            'TeacherZone',
                            style: AppStyles.mainTextStyle.copyWith(
                              color: AppColors.secondaryColor,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: AppColors.secondaryColor.withValues(
                                    alpha: 0.5,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Loading indicator
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.secondaryColor.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.secondaryColor,
                      ),
                      minHeight: 3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // بناء الدوائر المتحركة في الخلفية
  Widget _buildAnimatedCircle(int index) {
    final sizes = [150.0, 200.0, 250.0, 180.0, 220.0];
    final positions = [
      const Alignment(-0.8, -0.8),
      const Alignment(0.8, -0.6),
      const Alignment(-0.6, 0.8),
      const Alignment(0.6, 0.7),
      const Alignment(0.0, -0.3),
    ];

    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final offset = (index * 0.2) % 1.0;
        final animationValue = (_particleAnimation.value + offset) % 1.0;

        return Positioned.fill(
          child: Align(
            alignment: positions[index],
            child: Transform.scale(
              scale: 0.5 + (animationValue * 0.5),
              child: Opacity(
                opacity: 0.1 + (animationValue * 0.1),
                child: Container(
                  width: sizes[index],
                  height: sizes[index],
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.secondaryColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
