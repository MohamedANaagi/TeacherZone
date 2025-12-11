

import 'package:flutter/cupertino.dart';


import 'app_color.dart';
import 'app_fonts.dart';

class AppStyles {
  // النص الرئيسي - للعناوين الكبيرة
  static TextStyle mainTextStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );
  
  // النص الثانوي - للنصوص على خلفية ملونة
  static TextStyle subTextStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryColor,
  );
  
  // النص العادي - للنصوص السوداء/الداكنة
  static TextStyle black16w500Style = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  
  // النص الرمادي - للنصوص الثانوية
  static TextStyle grey12MediumStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
  
  // أنماط إضافية
  static TextStyle textPrimaryStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static TextStyle textSecondaryStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  static TextStyle headingStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static TextStyle subHeadingStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );



}
