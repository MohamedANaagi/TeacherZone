import 'package:flutter/material.dart';
import '../../../core/styling/app_color.dart';
import '../../../core/styling/app_styles.dart';

class PrimaryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;

  const PrimaryAppBar({
    super.key,
    required this.title,
    this.automaticallyImplyLeading = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: Text(
        title,
        style: AppStyles.mainTextStyle.copyWith(
          color: AppColors.blackColor,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.secondaryColor,
      elevation: 2.0, // إضافة ظل خفيف لتحسين الشكل
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.blackColor),
    );
  }
}
