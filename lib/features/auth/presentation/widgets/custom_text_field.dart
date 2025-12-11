import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final int? maxLines;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.textAlign,
    required this.textDirection,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.maxLines = 1,
  });

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
          textAlign: textAlign,
          textDirection: textDirection,
          keyboardType: keyboardType,
          validator: validator,
          obscureText: obscureText,
          maxLines: maxLines,
          style: AppStyles.textPrimaryStyle.copyWith(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppStyles.grey12MediumStyle.copyWith(fontSize: 14),
            prefixIcon: Icon(icon, color: AppColors.primaryColor),
            filled: true,
            fillColor: AppColors.secondaryColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
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
        ),
      ),
    );
  }
}
