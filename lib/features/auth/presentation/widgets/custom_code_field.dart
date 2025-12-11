import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class CustomCodeField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomCodeField({super.key, required this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextFormField(
          controller: controller,
          textAlign: TextAlign.center,
          style: AppStyles.textPrimaryStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
          decoration: InputDecoration(
            hintText: 'أدخل الكود هنا',
            hintStyle: AppStyles.grey12MediumStyle.copyWith(
              fontSize: 16,
              letterSpacing: 1,
            ),
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.primaryColor,
              size: 24,
            ),
            filled: true,
            fillColor: AppColors.secondaryColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.secondaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.errorColor,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
          ),
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'من فضلك أدخل الكود';
                }
                return null;
              },
        ),
      ),
    );
  }
}
