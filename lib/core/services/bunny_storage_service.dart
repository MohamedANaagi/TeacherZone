import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Service للتعامل مع Bunny Storage
/// يقوم برفع الفيديوهات إلى Bunny Storage وإرجاع URL
class BunnyStorageService {
  // قيم Bunny Storage
  static const String _storageZoneName = 'teacherzone'; // اسم Storage Zone
  static const String _apiKey = '97994d37-d3bb-4886-b4f5bd1009de-dba1-4041'; // API Key من Bunny Storage
  static const String _baseUrl = 'https://storage.bunnycdn.com'; // Base URL لـ Bunny Storage
  static const String _cdnUrl = 'https://teacherzone.b-cdn.net'; // CDN URL

  /// رفع فيديو إلى Bunny Storage
  /// 
  /// [videoFile] - ملف الفيديو المراد رفعه (لـ iOS و Android)
  /// [videoBytes] - bytes الفيديو (للويب)
  /// [fileName] - اسم الملف (مطلوب)
  /// 
  /// Returns URL الفيديو بعد الرفع
  /// Throws Exception في حالة فشل الرفع
  static Future<String> uploadVideo({
    File? videoFile,
    Uint8List? videoBytes,
    required String fileName,
  }) async {
    try {
      if (fileName.isEmpty) {
        throw Exception('اسم الملف مطلوب');
      }

      // قراءة محتوى الملف
      Uint8List fileBytes;
      if (kIsWeb) {
        // للويب: استخدام bytes مباشرة
        if (videoBytes == null) {
          throw Exception('يجب توفير videoBytes للويب');
        }
        fileBytes = videoBytes;
      } else {
        // لـ iOS و Android: قراءة من File
        if (videoFile == null) {
          throw Exception('يجب توفير videoFile لـ iOS و Android');
        }
        fileBytes = await videoFile.readAsBytes();
      }
      
      // بناء URL للرفع
      final uploadUrl = '$_baseUrl/$_storageZoneName/$fileName';
      
      debugPrint('🚀 بدء رفع الفيديو: $fileName');
      debugPrint('📦 حجم الملف: ${(fileBytes.length / 1024 / 1024).toStringAsFixed(2)} MB');
      
      // رفع الملف
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'AccessKey': _apiKey,
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // بناء CDN URL
        final videoUrl = '$_cdnUrl/$fileName';
        debugPrint('✅ تم رفع الفيديو بنجاح: $videoUrl');
        return videoUrl;
      } else {
        debugPrint('❌ فشل رفع الفيديو: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('فشل رفع الفيديو: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في رفع الفيديو: $e');
      rethrow;
    }
  }

  /// حذف فيديو من Bunny Storage
  /// 
  /// [fileName] - اسم الملف المراد حذفه
  static Future<void> deleteVideo(String fileName) async {
    try {
      final deleteUrl = '$_baseUrl/$_storageZoneName/$fileName';
      
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'AccessKey': _apiKey,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 404) {
        debugPrint('✅ تم حذف الفيديو: $fileName');
      } else {
        debugPrint('❌ فشل حذف الفيديو: ${response.statusCode}');
        throw Exception('فشل حذف الفيديو: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف الفيديو: $e');
      rethrow;
    }
  }

  /// رفع صورة إلى Bunny Storage
  /// 
  /// [imageFile] - ملف الصورة المراد رفعه (لـ iOS و Android)
  /// [imageBytes] - bytes الصورة (للويب)
  /// [fileName] - اسم الملف (مطلوب)
  /// 
  /// Returns URL الصورة بعد الرفع
  /// Throws Exception في حالة فشل الرفع
  static Future<String> uploadImage({
    File? imageFile,
    Uint8List? imageBytes,
    required String fileName,
  }) async {
    try {
      if (fileName.isEmpty) {
        throw Exception('اسم الملف مطلوب');
      }

      // قراءة محتوى الملف
      Uint8List fileBytes;
      if (kIsWeb) {
        // للويب: استخدام bytes مباشرة
        if (imageBytes == null) {
          throw Exception('يجب توفير imageBytes للويب');
        }
        fileBytes = imageBytes;
      } else {
        // لـ iOS و Android: قراءة من File
        if (imageFile == null) {
          throw Exception('يجب توفير imageFile لـ iOS و Android');
        }
        fileBytes = await imageFile.readAsBytes();
      }
      
      // بناء URL للرفع
      final uploadUrl = '$_baseUrl/$_storageZoneName/$fileName';
      
      debugPrint('🚀 بدء رفع الصورة: $fileName');
      debugPrint('📦 حجم الملف: ${(fileBytes.length / 1024).toStringAsFixed(2)} KB');
      
      // رفع الملف
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'AccessKey': _apiKey,
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // بناء CDN URL
        final imageUrl = '$_cdnUrl/$fileName';
        debugPrint('✅ تم رفع الصورة بنجاح: $imageUrl');
        return imageUrl;
      } else {
        debugPrint('❌ فشل رفع الصورة: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        throw Exception('فشل رفع الصورة: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في رفع الصورة: $e');
      rethrow;
    }
  }

  /// حذف صورة من Bunny Storage
  /// 
  /// [fileName] - اسم الملف المراد حذفه
  static Future<void> deleteImage(String fileName) async {
    try {
      final deleteUrl = '$_baseUrl/$_storageZoneName/$fileName';
      
      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {
          'AccessKey': _apiKey,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 404) {
        debugPrint('✅ تم حذف الصورة: $fileName');
      } else {
        debugPrint('❌ فشل حذف الصورة: ${response.statusCode}');
        throw Exception('فشل حذف الصورة: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ خطأ في حذف الصورة: $e');
      rethrow;
    }
  }

  /// استخراج اسم الملف من URL (مع المسار الكامل)
  /// 
  /// [url] - URL الفيديو أو الصورة (مثل: https://teacherzone.b-cdn.net/questions/question_123.jpg)
  /// Returns اسم الملف مع المسار الكامل (مثل: questions/question_123.jpg)
  static String getFileNameFromUrl(String url) {
    try {
      debugPrint('🔍 استخراج اسم الملف من URL: $url');
      final uri = Uri.parse(url);
      
      // استخراج المسار من URL (بدون الـ domain)
      // مثال: https://teacherzone.b-cdn.net/questions/question_123.jpg
      // المسار: /questions/question_123.jpg
      var filePath = uri.path;
      
      // إزالة الـ leading slash إذا كان موجوداً
      if (filePath.startsWith('/')) {
        filePath = filePath.substring(1);
      }
      
      debugPrint('📝 المسار المستخرج: $filePath');
      
      // إذا كان المسار فارغاً، نحاول استخراج اسم الملف فقط
      if (filePath.isEmpty) {
        final fileName = path.basename(uri.path);
        debugPrint('📝 استخدام اسم الملف فقط: $fileName');
        return fileName;
      }
      
      return filePath;
    } catch (e) {
      debugPrint('❌ خطأ في استخراج اسم الملف: $e');
      return '';
    }
  }
}

