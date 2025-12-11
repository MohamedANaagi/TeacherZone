



import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_fonts.dart';
import 'app_styles.dart';

class AppThemes {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.accentColor,
      surface: AppColors.secondaryColor,
      background: AppColors.backgroundColor,
      error: AppColors.errorColor,
      onPrimary: AppColors.secondaryColor,
      onSecondary: AppColors.secondaryColor,
      onSurface: AppColors.textPrimary,
      onBackground: AppColors.textPrimary,
      onError: AppColors.secondaryColor,
    ),
    fontFamily: AppFonts.mainFontName,
    textTheme: TextTheme(
      displayLarge: AppStyles.mainTextStyle,
      displayMedium: AppStyles.headingStyle,
      displaySmall: AppStyles.subHeadingStyle,
      titleLarge: AppStyles.mainTextStyle,
      titleMedium: AppStyles.subHeadingStyle,
      titleSmall: AppStyles.black16w500Style,
      bodyLarge: AppStyles.textPrimaryStyle,
      bodyMedium: AppStyles.textSecondaryStyle,
      bodySmall: AppStyles.grey12MediumStyle,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.secondaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppStyles.headingStyle.copyWith(fontSize: 20),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        elevation: 2,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.secondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.secondaryColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );
}