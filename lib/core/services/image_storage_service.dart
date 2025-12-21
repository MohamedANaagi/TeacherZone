import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// خدمة لحفظ وإدارة صور البروفايل محلياً في الجهاز
/// كل كود له صورة منفصلة محفوظة بناءً على الكود
class ImageStorageService {
  /// نسخ الصورة من الموقع المؤقت إلى مجلد التطبيق الدائم
  /// الصورة تُحفظ باسم الكود
  ///
  /// [sourcePath] مسار الصورة الأصلية (من image_picker)
  /// [code] كود المستخدم (يُستخدم كاسم الملف)
  /// Returns مسار الصورة الجديدة في مجلد التطبيق
  static Future<String> saveProfileImage({
    required String sourcePath,
    required String code,
  }) async {
    try {
      // التحقق من وجود الملف المصدر
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) {
        throw Exception('الصورة المختارة غير موجودة');
      }

      // الحصول على امتداد الملف الأصلي
      final fileExtension = path.extension(sourcePath).toLowerCase();
      // إذا لم يكن هناك امتداد، استخدم .jpg كافتراضي
      final extension = fileExtension.isNotEmpty ? fileExtension : '.jpg';
      // تحويل امتدادات HEIC و HEIF إلى jpg
      final finalExtension = (extension == '.heic' || extension == '.heif') ? '.jpg' : extension;

      // الحصول على مجلد التطبيق الدائم
      final appDir = await getApplicationDocumentsDirectory();
      final profileImageDir = Directory(path.join(appDir.path, 'profile_images'));

      // إنشاء المجلد إذا لم يكن موجوداً
      if (!await profileImageDir.exists()) {
        await profileImageDir.create(recursive: true);
      }

      // مسار الصورة الجديدة بناءً على الكود
      final fileName = '$code$finalExtension';
      final destinationPath = path.join(profileImageDir.path, fileName);

      // حذف الصورة القديمة إذا كانت موجودة (بأي امتداد)
      final extensions = ['.jpg', '.jpeg', '.png', '.heic', '.heif'];
      for (final ext in extensions) {
        try {
          final oldFile = File(path.join(profileImageDir.path, '$code$ext'));
          if (await oldFile.exists()) {
            await oldFile.delete();
          }
        } catch (e) {
          // تجاهل الأخطاء
        }
      }

      // نسخ الصورة من الموقع المؤقت إلى المجلد الدائم
      final savedFile = await sourceFile.copy(destinationPath);

      // التحقق من نجاح النسخ
      if (!await savedFile.exists()) {
        throw Exception('فشل نسخ الصورة');
      }

      return savedFile.path;
    } catch (e) {
      throw Exception('فشل حفظ الصورة: ${e.toString()}');
    }
  }

  /// حذف صورة البروفايل المحفوظة بناءً على الكود
  static Future<void> deleteProfileImage({required String code}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileImageDir = Directory(path.join(appDir.path, 'profile_images'));

      // حذف الصورة بجميع الامتدادات المحتملة
      final extensions = ['.jpg', '.jpeg', '.png', '.heic', '.heif'];
      for (final ext in extensions) {
        try {
          final imageFile = File(path.join(profileImageDir.path, '$code$ext'));
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (e) {
          // تجاهل الأخطاء
        }
      }
    } catch (e) {
      // تجاهل الأخطاء عند حذف الصورة
    }
  }

  /// التحقق من وجود صورة البروفايل بناءً على الكود
  static Future<bool> profileImageExists({required String code}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileImageDir = Directory(path.join(appDir.path, 'profile_images'));

      // التحقق من وجود الصورة بأي امتداد
      final extensions = ['.jpg', '.jpeg', '.png', '.heic', '.heif'];
      for (final ext in extensions) {
        final imageFile = File(path.join(profileImageDir.path, '$code$ext'));
        if (await imageFile.exists()) {
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// الحصول على مسار صورة البروفايل المحفوظة بناءً على الكود
  static Future<String?> getProfileImagePath({required String code}) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final profileImageDir = Directory(path.join(appDir.path, 'profile_images'));

      debugPrint('البحث عن الصورة للكود: $code');
      debugPrint('مجلد الصور: ${profileImageDir.path}');

      // التحقق من وجود المجلد
      if (!await profileImageDir.exists()) {
        debugPrint('مجلد الصور غير موجود');
        return null;
      }

      // البحث عن الصورة بأي امتداد
      final extensions = ['.jpg', '.jpeg', '.png', '.heic', '.heif'];
      for (final ext in extensions) {
        final imageFile = File(path.join(profileImageDir.path, '$code$ext'));
        debugPrint('التحقق من وجود: ${imageFile.path}');
        if (await imageFile.exists()) {
          debugPrint('تم العثور على الصورة: ${imageFile.path}');
          return imageFile.path;
        }
      }
      
      debugPrint('لم يتم العثور على صورة للكود: $code');
      return null;
    } catch (e) {
      debugPrint('خطأ في جلب مسار الصورة: $e');
      return null;
    }
  }
}

