

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/styling/app_color.dart';
import '../../../core/styling/app_styles.dart';
import '../../core/router/app_routers.dart';

class CodeInputScreen extends StatefulWidget {
  const CodeInputScreen({super.key});

  @override
  State<CodeInputScreen> createState() => _CodeInputScreenState();
}

class _CodeInputScreenState extends State<CodeInputScreen> {
  final TextEditingController _codeController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  late  TextEditingController  emailController ;

  late TextEditingController  passwordController;

  void _onLoginPressed() {
    final code = _codeController.text.trim();

    // لسه مفيش لوجيك، دي UI بس
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('من فضلك أدخل الكود')),
      );

    } else{
      context.go(AppRouters.mainScreen);
    }

    // TODO: هنا بعدين هنضيف التحقق من الكود و الانتقال للكورس
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 120),

              // اسم الأب
              Text(
                'TeacherZone',
                textAlign: TextAlign.center,
                style: AppStyles.mainTextStyle.copyWith(
                  color: AppColors.primaryColor,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'ادخل الكود الذي أعطاه لك المدرّس',
                textAlign: TextAlign.center,
                style: AppStyles.grey12MediumStyle.copyWith(
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 80),

              // TextField للكود
              TextFormField(

                controller: _codeController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'أدخل الكود هنا',
                  hintStyle: AppStyles.grey12MediumStyle.copyWith(
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.greyColor.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.greyColor.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // زرار الدخول
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _onLoginPressed,
                  style: ElevatedButton.styleFrom(

                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'دخول',
                    style: AppStyles.subTextStyle.copyWith(
                      color: AppColors.secondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              // "ليس لديك كود؟"
              Center(
                child: TextButton(
                  onPressed: () {
                    // هنا بعدين ممكن تودّي لصفحة:
                    // تواصل مع المدرّس / اشترك الآن / إلخ
                  },
                  child: Text(
                    'ليس لديك كود؟',
                    style: AppStyles.black16w500Style.copyWith(
                      fontSize: 15,
                      color: AppColors.greyColor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
