import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../../../core/cubit/user_cubit.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_code_field.dart';

class CodeInputScreen extends StatefulWidget {
  const CodeInputScreen({super.key});

  @override
  State<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen>
    with TickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade Animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // Slide Animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Scale Animation
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

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

    // Start animations
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
    _codeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final code = _codeController.text.trim();
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();

      // تسجيل الدخول
      final user = await InjectionContainer.loginUseCase(
        code: code,
        name: name,
        email: email,
      );

      // حفظ بيانات المستخدم في UserCubit
      if (!mounted) return;
      final userCubit = context.read<UserCubit>();
      await userCubit.updateUser(
        name: user.name,
        email: user.email,
        subscriptionEndDate: user.subscriptionEndDate,
        isLoggedIn: true,
      );

      // الانتقال للشاشة الرئيسية
      if (mounted) {
        context.go(AppRouters.mainScreen);
      }
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.message)),
              ],
            ),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(e.message)),
              ],
            ),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('حدث خطأ غير متوقع: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppColors.errorColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
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
      body: RepaintBoundary(
        child: Container(
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 40),

                      // Logo/Icon مع Animation
                      RepaintBoundary(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.secondaryColor.withOpacity(
                                  0.2,
                                ),
                                border: Border.all(
                                  color: AppColors.secondaryColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 50,
                                color: AppColors.secondaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // اسم التطبيق مع Animation
                      RepaintBoundary(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Text(
                              'TeacherZone',
                              textAlign: TextAlign.center,
                              style: AppStyles.mainTextStyle.copyWith(
                                color: AppColors.secondaryColor,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: AppColors.secondaryColor.withOpacity(
                                      0.5,
                                    ),
                                    blurRadius: 15,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // النص التوضيحي مع Animation
                      RepaintBoundary(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Text(
                              'أدخل بياناتك للدخول',
                              textAlign: TextAlign.center,
                              style: AppStyles.subTextStyle.copyWith(
                                fontSize: 16,
                                color: AppColors.secondaryColor.withOpacity(
                                  0.9,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 50),

                      // حقل الاسم مع Animation
                      RepaintBoundary(
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.15),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(
                                    0.3,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: _fadeController,
                                    curve: const Interval(0.3, 1.0),
                                  ),
                                ),
                            child: CustomTextField(
                              controller: _nameController,
                              hintText: 'أدخل اسمك',
                              icon: Icons.person_outline,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'من فضلك أدخل اسمك';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // حقل الإيميل مع Animation
                      RepaintBoundary(
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(
                                    0.3,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: _fadeController,
                                    curve: const Interval(0.4, 1.0),
                                  ),
                                ),
                            child: CustomTextField(
                              controller: _emailController,
                              hintText: 'أدخل بريدك الإلكتروني',
                              icon: Icons.email_outlined,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'من فضلك أدخل بريدك الإلكتروني';
                                }
                                if (!value.contains('@')) {
                                  return 'من فضلك أدخل بريد إلكتروني صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // حقل الكود مع Animation
                      RepaintBoundary(
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(
                                    0.4,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: _fadeController,
                                    curve: const Interval(0.5, 1.0),
                                  ),
                                ),
                            child: CustomCodeField(controller: _codeController),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // زرار الدخول مع Animation
                      RepaintBoundary(
                        child: SlideTransition(
                          position:
                              Tween<Offset>(
                                begin: const Offset(0, 0.2),
                                end: Offset.zero,
                              ).animate(
                                CurvedAnimation(
                                  parent: _slideController,
                                  curve: const Interval(
                                    0.6,
                                    1.0,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              ),
                          child: FadeTransition(
                            opacity: Tween<double>(begin: 0.0, end: 1.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: _fadeController,
                                    curve: const Interval(0.6, 1.0),
                                  ),
                                ),
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondaryColor
                                          .withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: _isLoading
                                      ? null
                                      : _onLoginPressed,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondaryColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                  AppColors.primaryColor,
                                                ),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'دخول',
                                              style: AppStyles.subTextStyle
                                                  .copyWith(
                                                    color:
                                                        AppColors.primaryColor,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward,
                                              color: AppColors.primaryColor,
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // "ليس لديك كود؟" مع Animation
                      FadeTransition(
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
                                color: AppColors.secondaryColor.withOpacity(
                                  0.9,
                                ),
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.secondaryColor
                                    .withOpacity(0.9),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
