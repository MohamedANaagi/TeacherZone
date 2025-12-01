



import 'package:flutter/material.dart';

import 'app_color.dart';
import 'app_fonts.dart';
import 'app_styles.dart';

class AppThemes{
  static final  lightTheme = ThemeData(
    primaryColor:  AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.secondaryColor,
    fontFamily: AppFonts.mainFontName,
    textTheme:  TextTheme(
     titleLarge: AppStyles.mainTextStyle,
      titleMedium: AppStyles.subTextStyle,

    ),
    buttonTheme: ButtonThemeData(
      buttonColor: AppColors.primaryColor,
      disabledColor: AppColors.secondaryColor,
    ),
  );
}