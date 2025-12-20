import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/router/app_routers.dart';

/// Widget لزر خفي في الزاوية اليمنى العلوية للوصول إلى لوحة الإدارة
/// يستخدم GestureDetector للكشف عن الضغط على منطقة شفافة
class AdminHiddenButton extends StatelessWidget {
  const AdminHiddenButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRouters.adminMainScreen);
      },
      child: Container(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(width: 50, height: 50, color: Colors.transparent),
      ),
    );
  }
}
