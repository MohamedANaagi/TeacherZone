

import 'package:flutter/cupertino.dart';


import 'app_color.dart';
import 'app_fonts.dart';

class AppStyles {
  static TextStyle  mainTextStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryColor,
  );
  static TextStyle  subTextStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryColor,
  );
  static TextStyle black16w500Style = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.blackColor,
  );
  static TextStyle grey12MediumStyle = TextStyle(
    fontFamily: AppFonts.mainFontName,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.greyColor,
  );



}
