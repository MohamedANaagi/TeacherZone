import '../../../user/presentation/cubit/user_cubit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
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
    try {
      _fadeController.forward();
    } catch (e) {
      debugPrint('خطأ في تشغيل fade animation: $e');
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        try {
          _slideController.forward();
        } catch (e) {
          debugPrint('خطأ في تشغيل slide animation: $e');
        }
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        try {
          _scaleController.forward();
        } catch (e) {
          debugPrint('خطأ في تشغيل scale animation: $e');
        }
      }
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
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      // جمع البيانات من الحقول
      final code = _codeController.text.trim();

      // استدعاء LoginUseCase لتسجيل الدخول
      final user = await InjectionContainer.loginUseCase(code: code);

      // جلب CodeModel للحصول على profileImageUrl من Bunny Storage
      String? profileImageUrl;
      try {
        final codeModel = await InjectionContainer.adminRepo.getCodeByCode(
          code,
        );
        profileImageUrl = codeModel?.profileImageUrl;
        if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
          debugPrint('تم العثور على صورة من Bunny Storage: $profileImageUrl');
        }
      } catch (e) {
        debugPrint('⚠️ خطأ في جلب profileImageUrl: $e');
      }

      // جلب adminCode من الكود
      String? adminCode;
      try {
        adminCode = await InjectionContainer.adminRepo.getAdminCodeByUserCode(
          code,
        );
      } catch (e) {
        debugPrint('⚠️ خطأ في جلب adminCode: $e');
      }

      // حفظ بيانات المستخدم في UserCubit
      if (!mounted) return;
      try {
        final userCubit = context.read<UserCubit>();
        await userCubit.updateUser(
          name: user.name,
          phone: user.phone,
          code: code,
          adminCode: adminCode,
          imagePath: profileImageUrl, // URL من Bunny Storage
          subscriptionEndDate: user.subscriptionEndDate,
          isLoggedIn: true,
        );
      } catch (e) {
        debugPrint('خطأ في حفظ بيانات المستخدم: $e');
        if (mounted) {
          ErrorSnackBarHelper.showError(
            context,
            'حدث خطأ في حفظ بيانات المستخدم',
          );
        }
        return;
      }

      // الانتقال للشاشة الرئيسية
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
      appBar: kIsWeb
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: AppColors.secondaryColor,
                    size: 24,
                  ),
                ),
                onPressed: () {
                  // الرجوع إلى صفحة Landing Page في الويب فقط
                  try {
                    if (mounted) {
                      context.go(AppRouters.landingPageScreen);
                    }
                  } catch (e) {
                    debugPrint('خطأ في الرجوع إلى Landing Page: $e');
                    // محاولة بديلة باستخدام Navigator
                    try {
                      if (mounted && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    } catch (_) {
                      debugPrint('فشل الرجوع بالكامل');
                    }
                  }
                },
              ),
            )
          : null, // لا يوجد AppBar في الموبايل
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

  Future<void> _handleSubmit() async {
    final enteredCode = _codeController.text.trim();

    if (enteredCode.isEmpty) {
      ErrorSnackBarHelper.showError(context, 'الرجاء إدخال كود الأدمن');
      return;
    }

    // إظهار loading indicator
    if (!mounted) return;
    bool loadingDialogShown = false;
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      loadingDialogShown = true;
    } catch (e) {
      debugPrint('خطأ في إظهار loading dialog: $e');
    }

    try {
      // البحث مباشرة في collection adminCodes لجلب AdminCodeModel بالكامل
      final adminCodeModel = await InjectionContainer.adminRepo
          .getAdminCodeModelByCode(enteredCode);

      // إغلاق loading dialog
      if (mounted && loadingDialogShown) {
        try {
          Navigator.of(context).pop();
        } catch (e) {
          debugPrint('خطأ في إغلاق loading dialog: $e');
        }
      }

      if (adminCodeModel == null) {
        if (mounted) {
          try {
            Navigator.of(context).pop(); // إغلاق dialog كود الأدمن
          } catch (e) {
            debugPrint('خطأ في إغلاق dialog: $e');
          }
          ErrorSnackBarHelper.showError(context, 'كود الأدمن غير صحيح');
        }
        return;
      }

      // حفظ adminCode و adminName و adminPhone و adminDescription و adminImageUrl في UserCubit
      if (mounted) {
        try {
          final userCubit = context.read<UserCubit>();
          await userCubit.updateUser(
            adminCode: adminCodeModel.adminCode,
            adminName: adminCodeModel.name,
            adminPhone: adminCodeModel.phone,
            adminDescription: adminCodeModel.description,
            adminImageUrl: adminCodeModel.imageUrl,
            isLoggedIn: true,
          );
        } catch (e) {
          debugPrint('خطأ في حفظ بيانات الأدمن: $e');
          if (mounted) {
            try {
              Navigator.of(context).pop(); // إغلاق dialog كود الأدمن
            } catch (_) {}
            ErrorSnackBarHelper.showError(
              context,
              'حدث خطأ في حفظ بيانات الأدمن',
            );
          }
          return;
        }

        // الانتقال لشاشة الأدمن
        if (mounted) {
          try {
            Navigator.of(context).pop(); // إغلاق dialog كود الأدمن
            context.push(AppRouters.adminMainScreen);
          } catch (e) {
            debugPrint('خطأ في الانتقال لشاشة الأدمن: $e');
            // محاولة بديلة
            try {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              if (mounted) {
                Navigator.of(context).pushNamed(AppRouters.adminMainScreen);
              }
            } catch (_) {
              debugPrint('فشل الانتقال بالكامل');
            }
          }
        }
      }
    } catch (e) {
      debugPrint('خطأ في التحقق من كود الأدمن: $e');
      if (mounted) {
        // إغلاق loading dialog إذا كان مفتوحاً
        if (loadingDialogShown) {
          try {
            Navigator.of(context).pop();
          } catch (_) {}
        }
        // إغلاق dialog كود الأدمن
        try {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        } catch (_) {}
        ErrorSnackBarHelper.showError(
          context,
          'حدث خطأ أثناء التحقق من كود الأدمن',
        );
      }
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
          hintStyle: AppStyles.textSecondaryStyle.copyWith(fontSize: 14),
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
        keyboardType: TextInputType.text,
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
            try {
              if (mounted && Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              debugPrint('خطأ في إغلاق dialog: $e');
            }
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
