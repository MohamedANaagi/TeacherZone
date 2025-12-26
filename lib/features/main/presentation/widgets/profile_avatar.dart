import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/styling/app_color.dart';

/// Widget لعرض صورة المستخدم مع إمكانية التعديل
/// يعرض الصورة المخصصة أو صورة افتراضية مع زر كاميرا للتحرير
class ProfileAvatar extends StatelessWidget {
  /// مسار صورة المستخدم (إذا كانت موجودة)
  final String? imagePath;

  /// Callback يتم استدعاؤها عند الضغط على الصورة لتغييرها
  final VoidCallback onTap;

  const ProfileAvatar({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // صورة المستخدم
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: imagePath != null && imagePath!.isNotEmpty
                  ? _buildImage(imagePath!)
                  : _buildDefaultAvatar(),
            ),
          ),
          // زر الكاميرا في الزاوية
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondaryColor, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: AppColors.secondaryColor,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء الصورة من URL أو المسار المحلي
  Widget _buildImage(String imagePath) {
    // التحقق من أن imagePath هو URL (يبدأ بـ http أو https)
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      // مسار محلي
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }
  }

  /// بناء الصورة الافتراضية عند عدم وجود صورة للمستخدم
  Widget _buildDefaultAvatar() {
    return Container(
      color: AppColors.primaryColor.withValues(alpha: 0.1),
      child: Icon(Icons.person, size: 60, color: AppColors.primaryColor),
    );
  }
}
