import '../../../user/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/image_storage_service.dart';
import '../widgets/custom_code_field.dart';
import '../widgets/login_app_logo.dart';
import '../widgets/login_app_title.dart';
import '../widgets/login_subtitle.dart';
import '../widgets/login_button.dart';
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

      // محاولة تحميل الصورة المحفوظة محلياً بناءً على الكود
      String? profileImagePath;
      try {
        debugPrint('محاولة تحميل الصورة للكود: $code');
        profileImagePath = await ImageStorageService.getProfileImagePath(code: code);
        if (profileImagePath != null) {
          debugPrint('تم العثور على الصورة: $profileImagePath');
        } else {
          debugPrint('لم يتم العثور على صورة للكود: $code');
        }
      } catch (e) {
        // تجاهل الأخطاء عند جلب الصورة المحلية
        debugPrint('خطأ في جلب الصورة المحلية: $e');
      }

      // حفظ بيانات المستخدم في UserCubit
      if (!mounted) return;
      final userCubit = context.read<UserCubit>();
      await userCubit.updateUser(
        name: user.name,
        phone: user.phone,
        code: code,
        imagePath: profileImagePath,
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

              // زر الأدمن
              _buildAdminButton(),
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

  /// بناء زر الأدمن مع تأثير animation
  Widget _buildAdminButton() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _fadeController,
          curve: const Interval(0.7, 1.0),
        ),
      ),
      child: Center(
        child: TextButton(
          onPressed: _showAdminDialog,
          child: Text(
            'هل أنت أدمن؟',
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

  /// عرض حوار إدخال كود الأدمن
  void _showAdminDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _AdminDialogContent();
      },
    );
  }
}

/// Widget منفصل لإدارة حوار كود الأدمن
class _AdminDialogContent extends StatefulWidget {
  const _AdminDialogContent();

  @override
  State<_AdminDialogContent> createState() => _AdminDialogContentState();
}

class _AdminDialogContentState extends State<_AdminDialogContent> {
  late final TextEditingController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final enteredCode = _codeController.text.trim();
    Navigator.of(context).pop();
    if (enteredCode == '3082002') {
      context.push(AppRouters.adminMainScreen);
    } else {
      ErrorSnackBarHelper.showError(context, 'كود الأدمن غير صحيح');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.secondaryColor,
      title: Text(
        'كود الأدمن',
        style: AppStyles.subHeadingStyle,
        textDirection: TextDirection.rtl,
      ),
      content: TextField(
        controller: _codeController,
        obscureText: false, // جعل النص ظاهراً بوضوح
        decoration: InputDecoration(
          labelText: 'أدخل كود الأدمن',
          labelStyle: AppStyles.textSecondaryStyle,
          hintText: 'أدخل الكود هنا',
          hintStyle: AppStyles.textSecondaryStyle.copyWith(
            fontSize: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          ),
          filled: true,
          fillColor: AppColors.backgroundLight,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        style: AppStyles.subTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 2,
          color: AppColors.textPrimary,
        ),
        autofocus: true,
        onSubmitted: (_) => _handleSubmit(),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'إلغاء',
            style: AppStyles.textSecondaryStyle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'دخول',
            style: AppStyles.subTextStyle.copyWith(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      actionsAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
