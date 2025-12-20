import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../../../core/services/onboarding_service.dart';
import '../../../user/presentation/cubit/user_cubit.dart';

/// شاشة البداية (Splash Screen)
/// تعرض شعار التطبيق مع animations وتحدد الشاشة التالية بناءً على حالة المستخدم
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _mainController; // للتحكم في Animation الرئيسية
  late AnimationController _pulseController; // للتحكم في Animation النبض
  late AnimationController _particleController; // للتحكم في Animation الدوائر

  // Animations
  late Animation<double> _scaleAnimation; // animation للتكبير/التصغير
  late Animation<double> _fadeAnimation; // animation للشفافية
  late Animation<double> _rotationAnimation; // animation للدوران
  late Animation<double> _pulseAnimation; // animation للنبض المتكرر
  late Animation<double> _particleAnimation; // animation للدوائر في الخلفية

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateAfterDelay();
  }

  /// تهيئة جميع Animation Controllers و Animations
  /// يتم استدعاؤها مرة واحدة عند تهيئة الشاشة
  void _initializeAnimations() {
    // Main Animation Controller - للتحكم في Animation الرئيسية (2 ثانية)
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // Pulse Animation Controller - للتحكم في Animation النبض (1.5 ثانية، متكرر)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Particle Animation Controller - للتحكم في Animation الدوائر (3 ثوان، متكرر)
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Scale Animation - من 0.0 إلى 1.0 مع تأثير elastic
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Fade Animation - من 0.0 إلى 1.0 (شفافية)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    // Rotation Animation - دوران بسيط (0.0 إلى 0.1)
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.1).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Pulse Animation - نبض من 1.0 إلى 1.1 (تكبير/تصغير)
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Particle Animation - للدوائر في الخلفية (من 0.0 إلى 1.0)
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    // بدء Animation الرئيسية
    _mainController.forward();
  }

  /// معالجة الانتقال بعد انتهاء Animation
  ///
  /// الخطوات:
  /// 1. انتظار 100ms لضمان تهيئة الشاشة
  /// 2. تحميل بيانات المستخدم من SharedPreferences
  /// 3. انتظار 3.5 ثانية لعرض Animation
  /// 4. التحقق من حالة تسجيل الدخول:
  ///    - إذا كان مسجل دخول: الانتقال للشاشة الرئيسية
  ///    - إذا لم يكن مسجل دخول: التحقق من Onboarding:
  ///      * إذا تم عرضه: الانتقال لشاشة تسجيل الدخول
  ///      * إذا لم يتم عرضه: الانتقال لشاشة Onboarding
  Future<void> _navigateAfterDelay() async {
    // انتظار قصير لضمان تهيئة الشاشة بشكل كامل
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    // تحميل بيانات المستخدم من SharedPreferences
    final userCubit = context.read<UserCubit>();
    await userCubit.loadUserData();

    // انتظار 3.5 ثانية لعرض Animation قبل الانتقال
    await Future.delayed(const Duration(milliseconds: 3400));
    if (!mounted) return;

    // التحقق من حالة تسجيل الدخول
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
    // تنظيف جميع Animation Controllers عند تدمير الشاشة
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
          // دوائر متحركة في الخلفية
          ...List.generate(5, (index) => _buildAnimatedCircle(index)),

          // المحتوى الرئيسي
          _buildMainContent(),
        ],
      ),
    );
  }

  /// بناء المحتوى الرئيسي للشاشة
  /// يحتوي على الشعار، العنوان، ومؤشر التحميل
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الشعار مع تأثير الدوران
          _buildLogo(),
          const SizedBox(height: 40),

          // العنوان مع تأثيرات متعددة (fade, scale, pulse)
          _buildTitle(),
          const SizedBox(height: 20),

          // مؤشر التحميل
          _buildLoadingIndicator(),
        ],
      ),
    );
  }

  /// بناء الشعار مع تأثير الدوران
  /// يعرض أيقونة التطبيق داخل دائرة مع تأثير rotation
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.secondaryColor.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.secondaryColor, width: 3),
            ),
            child: Icon(
              Icons.school,
              size: 60,
              color: AppColors.secondaryColor,
            ),
          ),
        );
      },
    );
  }

  /// بناء عنوان التطبيق مع تأثيرات متعددة
  /// يجمع بين fade, scale, و pulse animations
  Widget _buildTitle() {
    return FadeTransition(
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
                      color: AppColors.secondaryColor.withValues(alpha: 0.5),
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
    );
  }

  /// بناء مؤشر التحميل
  /// يعرض LinearProgressIndicator مع تأثير fade
  Widget _buildLoadingIndicator() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        width: 200,
        child: LinearProgressIndicator(
          backgroundColor: AppColors.secondaryColor.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
          minHeight: 3,
        ),
      ),
    );
  }

  /// بناء الدوائر المتحركة في الخلفية
  ///
  /// [index] - الفهرس الخاص بالدائرة (0-4)
  ///
  /// يعرض 5 دوائر بأحجام ومواقع مختلفة مع تأثيرات scale و opacity متحركة
  Widget _buildAnimatedCircle(int index) {
    // أحجام مختلفة للدوائر
    final sizes = [150.0, 200.0, 250.0, 180.0, 220.0];

    // مواقع مختلفة للدوائر في الشاشة
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
        // حساب offset مختلف لكل دائرة لإنشاء تأثير متدرج
        final offset = (index * 0.2) % 1.0;
        final animationValue = (_particleAnimation.value + offset) % 1.0;

        return Positioned.fill(
          child: Align(
            alignment: positions[index],
            child: Transform.scale(
              // scale من 0.5 إلى 1.0 بناءً على animationValue
              scale: 0.5 + (animationValue * 0.5),
              child: Opacity(
                // opacity من 0.1 إلى 0.2 بناءً على animationValue
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
