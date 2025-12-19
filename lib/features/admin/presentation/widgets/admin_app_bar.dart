import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool automaticallyImplyLeading;

  const AdminAppBar({
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
          color: AppColors.textPrimary,
          fontSize: 20,
        ),
      ),
      backgroundColor: AppColors.secondaryColor,
      elevation: 2.0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
    );
  }
}
