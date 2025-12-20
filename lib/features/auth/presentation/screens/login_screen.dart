import '../../../user/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../widgets/custom_code_field.dart';
import '../widgets/login_app_logo.dart';
import '../widgets/login_app_title.dart';
import '../widgets/login_subtitle.dart';
import '../widgets/login_button.dart';
import '../widgets/admin_hidden_button.dart';
import '../widgets/animated_form_field.dart';
import '../widgets/error_snackbar_helper.dart';

/// شاشة تسجيل الدخول
/// تقوم بجمع بيانات المستخدم (الاسم، البريد الإلكتروني، الكود) وتسجيل الدخول
class CodeInputScreen extends StatefulWidget {
  const CodeInputScreen({super.key});

  @override
  State<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen>
    with TickerProviderStateMixin {
  // Controllers لحقول الإدخال
  final TextEditingController _codeController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Animation Controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  /// تهيئة جميع Animation Controllers و Animations
  /// يتم استدعاؤها مرة واحدة عند تهيئة الشاشة
  void _initializeAnimations() {
    // Fade Animation Controller - للشفافية
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Slide Animation Controller - للانزلاق
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Scale Animation Controller - للتكبير/التصغير
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // إنشاء Animations من Controllers
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  /// بدء تشغيل Animations بشكل متدرج
  /// Fade يبدأ أولاً، ثم Slide بعد 300ms، ثم Scale بعد 500ms
  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    // تنظيف جميع Controllers عند تدمير الشاشة
    _codeController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  /// معالجة الضغط على زر تسجيل الدخول
  ///
  /// الخطوات:
  /// 1. التحقق من صحة البيانات المدخلة
  /// 2. استدعاء LoginUseCase لتسجيل الدخول
  /// 3. حفظ بيانات المستخدم في UserCubit
  /// 4. الانتقال للشاشة الرئيسية
  /// 5. معالجة الأخطاء وعرضها للمستخدم
  Future<void> _onLoginPressed() async {
    // التحقق من صحة النموذج
    if (!formKey.currentState!.validate()) {
      return;
    }

    // تفعيل حالة التحميل
    setState(() {
      _isLoading = true;
    });

    try {
      // جمع البيانات من الحقول
      final code = _codeController.text.trim();

      // استدعاء LoginUseCase لتسجيل الدخول
      final user = await InjectionContainer.loginUseCase(code: code);

      // حفظ بيانات المستخدم في UserCubit
      if (!mounted) return;
      final userCubit = context.read<UserCubit>();
      await userCubit.updateUser(
        name: user.name,
        phone: user.phone,
        subscriptionEndDate: user.subscriptionEndDate,
        isLoggedIn: true,
      );

      // الانتقال للشاشة الرئيسية
      if (mounted) {
        context.go(AppRouters.mainScreen);
      }
    } on ValidationException catch (e) {
      // معالجة أخطاء التحقق من البيانات
      if (mounted) {
        ErrorSnackBarHelper.showError(context, e.message);
      }
    } on AuthException catch (e) {
      // معالجة أخطاء المصادقة
      if (mounted) {
        ErrorSnackBarHelper.showError(context, e.message);
      }
    } catch (e) {
      // معالجة الأخطاء العامة
      if (mounted) {
        ErrorSnackBarHelper.showError(
          context,
          'حدث خطأ غير متوقع: ${e.toString()}',
        );
      }
    } finally {
      // إلغاء حالة التحميل في جميع الأحوال
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor,
              AppColors.primaryDark,
              AppColors.primaryColor,
            ],
          ),
        ),
        child: SafeArea(child: RepaintBoundary(child: _buildLoginContent())),
      ),
    );
  }

  /// بناء محتوى الشاشة الرئيسي
  /// يحتوي على النموذج وجميع العناصر
  Widget _buildLoginContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // زر خفي للوصول إلى لوحة الإدارة
              const AdminHiddenButton(),
              const SizedBox(height: 40),

              // شعار التطبيق
              LoginAppLogo(
                fadeAnimation: _fadeAnimation,
                scaleAnimation: _scaleAnimation,
              ),
              const SizedBox(height: 30),

              // عنوان التطبيق
              LoginAppTitle(
                fadeAnimation: _fadeAnimation,
                slideAnimation: _slideAnimation,
              ),
              const SizedBox(height: 12),

              // النص التوضيحي
              LoginSubtitle(
                fadeAnimation: _fadeAnimation,
                slideAnimation: _slideAnimation,
              ),
              const SizedBox(height: 50),

              // حقل الكود
              _buildCodeField(),
              const SizedBox(height: 40),

              // زر الدخول
              LoginButton(
                onPressed: _onLoginPressed,
                isLoading: _isLoading,
                fadeAnimation: _fadeAnimation,
                slideController: _slideController,
                fadeController: _fadeController,
                scaleAnimation: _scaleAnimation,
              ),
              const SizedBox(height: 30),

              // رابط "ليس لديك كود؟"
              _buildNoCodeLink(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء حقل الإدخال للكود مع تأثيرات animation
  Widget _buildCodeField() {
    return AnimatedFormField(
      slideController: _slideController,
      fadeController: _fadeController,
      slideIntervalStart: 0.3,
      slideIntervalEnd: 1.0,
      fadeIntervalStart: 0.3,
      fadeIntervalEnd: 1.0,
      slideBegin: const Offset(0, 0.2),
      child: CustomCodeField(controller: _codeController),
    );
  }

  /// بناء رابط "ليس لديك كود؟" مع تأثير animation
  Widget _buildNoCodeLink() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.7, 1.0),
        ),
      ),
      child: Center(
        child: TextButton(
          onPressed: () {
            // TODO: إضافة صفحة التواصل
          },
          child: Text(
            'ليس لديك كود؟',
            style: AppStyles.subTextStyle.copyWith(
              fontSize: 15,
              color: AppColors.secondaryColor.withOpacity(0.9),
              decoration: TextDecoration.underline,
              decorationColor: AppColors.secondaryColor.withOpacity(0.9),
            ),
          ),
        ),
      ),
    );
  }
}
