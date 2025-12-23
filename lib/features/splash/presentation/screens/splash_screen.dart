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
  late AnimationController _mainController;
  late AnimationController _pulseController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateAfterDelay();
  }

  /// تهيئة Animations
  void _initializeAnimations() {
    // Main Animation Controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Pulse Animation Controller - نبض خفيف
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Fade Animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Scale Animation للشعار
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Slide Animation للعنوان
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Pulse Animation - نبض خفيف
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // بدء Animations
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

    // انتظار 2.5 ثانية لعرض Animation قبل الانتقال
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // التحقق من حالة تسجيل الدخول
    final isLoggedIn = userCubit.state.isLoggedIn;
    debugPrint('حالة تسجيل الدخول في Splash: $isLoggedIn');

    if (isLoggedIn) {
      // إذا كان المستخدم مسجل دخول، الانتقال للشاشة الرئيسية
      if (mounted) {
        try {
          context.go(AppRouters.mainScreen);
        } catch (e) {
          debugPrint('خطأ في الانتقال للشاشة الرئيسية: $e');
          // محاولة بديلة
          try {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(AppRouters.mainScreen);
            }
          } catch (_) {
            debugPrint('فشل الانتقال بالكامل');
          }
        }
      }
      return;
    }

    // التحقق من إذا كان تم عرض الـ Onboarding من قبل
    bool isCompleted = false;
    try {
      isCompleted = await OnboardingService.isOnboardingCompleted();
    } catch (e) {
      debugPrint('خطأ في التحقق من Onboarding: $e');
      // في حالة الخطأ، نعتبر أنه لم يتم إكمال Onboarding
      isCompleted = false;
    }

    if (isCompleted) {
      // إذا تم عرضها من قبل، الانتقال مباشرة لشاشة تسجيل الدخول
      if (mounted) {
        try {
          context.go(AppRouters.codeInputScreen);
        } catch (e) {
          debugPrint('خطأ في الانتقال لشاشة تسجيل الدخول: $e');
          try {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(AppRouters.codeInputScreen);
            }
          } catch (_) {
            debugPrint('فشل الانتقال بالكامل');
          }
        }
      }
    } else {
      // إذا لم يتم عرضها، الانتقال لشاشة الـ Onboarding
      if (mounted) {
        try {
          context.go(AppRouters.onBoardingScreen);
        } catch (e) {
          debugPrint('خطأ في الانتقال لشاشة Onboarding: $e');
          try {
            if (mounted) {
              Navigator.of(context).pushReplacementNamed(AppRouters.onBoardingScreen);
            }
          } catch (_) {
            debugPrint('فشل الانتقال بالكامل');
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: _buildMainContent(),
    );
  }

  /// بناء المحتوى الرئيسي للشاشة
  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الشعار مع animations
          _buildLogo(),
          const SizedBox(height: 50),

          // العنوان مع animations
          _buildTitle(),
        ],
      ),
    );
  }

  /// بناء الشعار مع animations
  Widget _buildLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.secondaryColor.withOpacity(0.2),
                      AppColors.secondaryColor.withOpacity(0.1),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.secondaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.school,
                  size: 55,
                  color: AppColors.secondaryColor,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// بناء عنوان التطبيق مع animations
  Widget _buildTitle() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Text(
          'TeacherZone',
          style: AppStyles.mainTextStyle.copyWith(
            color: AppColors.secondaryColor,
            fontSize: 38,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }

}
