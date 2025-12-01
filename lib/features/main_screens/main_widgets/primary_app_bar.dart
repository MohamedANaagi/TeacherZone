import 'package:flutter/material.dart';
import '../../../core/styling/app_color.dart';
import '../../../core/styling/app_styles.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const PrimaryAppBar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: AppStyles.mainTextStyle.copyWith(
          color: AppColors.blackColor,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.secondaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(
        color: AppColors.blackColor,
      ),
    );
  }
}
