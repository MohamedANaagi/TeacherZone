import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Service للتعامل مع Bunny Storage و Bunny Stream
/// الصور ترفع على Bunny Storage
/// الفيديوهات ترفع على Bunny Stream
class BunnyStorageService {
  // قيم Bunny Storage (للصور)
  static const String _storageZoneName = 'teacherzone'; // اسم Storage Zone
  static const String _storageApiKey =
      '97994d37-d3bb-4886-b4f5bd1009de-dba1-4041'; // API Key من Bunny Storage
  static const String _storageBaseUrl =
      'https://storage.bunnycdn.com'; // Base URL لـ Bunny Storage
  static const String _cdnUrl =
      'https://teacherzone.b-cdn.net'; // CDN URL للصور

  // قيم Bunny Stream (للفيديوهات)
  // TODO: قم بتحديث هذه القيم من لوحة تحكم Bunny Stream
  static const int _streamLibraryId = 570093; // Library ID من Bunny Stream
  static const String _streamApiKey =
      '9d9140b2-5221-461a-88dd5cbbb73c-5c17-481d'; // API Key من Bunny Stream
  static const String _streamBaseUrl =
      'https://video.bunnycdn.com'; // Base URL لـ Bunny Stream
  static const String _streamCdnUrl =
      'https://vz-c07dacb9-781.b-cdn.net'; // CDN URL للفيديوهات (استبدل YOUR_LIBRARY_ID بالرقم الفعلي)

  /// رفع فيديو إلى Bunny Stream
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

      debugPrint('🚀 بدء رفع الفيديو إلى Bunny Stream: $fileName');
      debugPrint(
        '📦 حجم الملف: ${(fileBytes.length / 1024 / 1024).toStringAsFixed(2)} MB',
      );

      // الخطوة 1: إنشاء فيديو جديد في Bunny Stream
      // استخدام libraryId كرقم في الـ URL
      final createVideoUrl = '$_streamBaseUrl/library/$_streamLibraryId/videos';
      debugPrint('🔗 Create Video URL: $createVideoUrl');
      debugPrint('🔑 Library ID: $_streamLibraryId');

      final createResponse = await http.post(
        Uri.parse(createVideoUrl),
        headers: {
          'AccessKey': _streamApiKey,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'title': path.basenameWithoutExtension(fileName)}),
      );

      debugPrint('📤 Create Response Status: ${createResponse.statusCode}');
      debugPrint('📤 Create Response Body: ${createResponse.body}');

      if (createResponse.statusCode != 200) {
        debugPrint(
          '❌ فشل إنشاء فيديو في Bunny Stream: ${createResponse.statusCode}',
        );
        debugPrint('Response: ${createResponse.body}');
        throw Exception(
          'فشل إنشاء فيديو: ${createResponse.statusCode} - ${createResponse.body}',
        );
      }

      final videoData = jsonDecode(createResponse.body) as Map<String, dynamic>;
      debugPrint('📋 Video Data Response: $videoData');

      // استخراج videoId من guid (هو String ويمكن استخدامه في URL)
      // videoLibraryId هو رقم (int) وليس مناسب للاستخدام في URL
      final videoId = videoData['guid'] as String?;

      if (videoId == null) {
        debugPrint('❌ فشل استخراج guid من الاستجابة');
        debugPrint(
          '📋 الحقول المتاحة في الاستجابة: ${videoData.keys.toList()}',
        );
        throw Exception(
          'فشل الحصول على videoId (guid) من Bunny Stream. Response: ${createResponse.body}',
        );
      }

      debugPrint('✅ تم إنشاء فيديو في Bunny Stream: $videoId');

      // الخطوة 2: رفع ملف الفيديو
      final uploadUrl =
          '$_streamBaseUrl/library/$_streamLibraryId/videos/$videoId';

      final uploadResponse = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'AccessKey': _streamApiKey,
          'Content-Type': 'application/octet-stream',
        },
        body: fileBytes,
      );

      if (uploadResponse.statusCode == 200 ||
          uploadResponse.statusCode == 201) {
        // بناء Stream URL للفيديو (بدون جودة محددة - سيتم تحديدها في المشغل)
        // نرجع base URL بدون جودة، وسيتم إضافة الجودة في مشغل الفيديو
        final videoUrl = '$_streamCdnUrl/$videoId';
        debugPrint('✅ تم رفع الفيديو بنجاح إلى Bunny Stream: $videoUrl');
        return videoUrl;
      } else {
        debugPrint('❌ فشل رفع الفيديو: ${uploadResponse.statusCode}');
        debugPrint('Response: ${uploadResponse.body}');
        throw Exception(
          'فشل رفع الفيديو: ${uploadResponse.statusCode} - ${uploadResponse.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ خطأ في رفع الفيديو: $e');
      rethrow;
    }
  }

  /// حذف فيديو من Bunny Stream
  ///
  /// [videoId] - ID الفيديو المراد حذفه (يمكن استخراجه من URL)
  static Future<void> deleteVideo(String videoId) async {
    try {
      // استخراج videoId من URL إذا كان URL كامل
      String actualVideoId = videoId;
      if (videoId.contains('/')) {
        final uri = Uri.parse(videoId);
        final pathParts = uri.path.split('/');
        if (pathParts.isNotEmpty) {
          actualVideoId =
              pathParts[pathParts.length - 2]; // الحصول على videoId من المسار
        }
      }

      final deleteUrl =
          '$_streamBaseUrl/library/$_streamLibraryId/videos/$actualVideoId';

      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {'AccessKey': _streamApiKey},
      );

      if (response.statusCode == 200 || response.statusCode == 404) {
        debugPrint('✅ تم حذف الفيديو من Bunny Stream: $actualVideoId');
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
      final uploadUrl = '$_storageBaseUrl/$_storageZoneName/$fileName';

      debugPrint('🚀 بدء رفع الصورة إلى Bunny Storage: $fileName');
      debugPrint(
        '📦 حجم الملف: ${(fileBytes.length / 1024).toStringAsFixed(2)} KB',
      );

      // رفع الملف
      final response = await http.put(
        Uri.parse(uploadUrl),
        headers: {
          'AccessKey': _storageApiKey,
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
        throw Exception(
          'فشل رفع الصورة: ${response.statusCode} - ${response.body}',
        );
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
      final deleteUrl = '$_storageBaseUrl/$_storageZoneName/$fileName';

      final response = await http.delete(
        Uri.parse(deleteUrl),
        headers: {'AccessKey': _storageApiKey},
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

  /// بناء URL الفيديو بجودة معينة من Bunny Stream
  ///
  /// [baseVideoUrl] - Base URL للفيديو (بدون جودة)
  /// [quality] - الجودة المطلوبة ('240p', '360p', '480p', '720p')
  /// [useHls] - استخدام HLS Playlist (افضل للجودة التكيفية) أو MP4 مباشر
  ///
  /// Returns URL الفيديو بالجودة المحددة
  static String getVideoUrlWithQuality(
    String baseVideoUrl,
    String quality, {
    bool useHls = false,
  }) {
    // إزالة أي جودة موجودة مسبقاً في URL
    String cleanUrl = baseVideoUrl;
    final qualityPattern = RegExp(r'/play_\d+p\.mp4$|/playlist\.m3u8$');
    if (qualityPattern.hasMatch(cleanUrl)) {
      cleanUrl = cleanUrl.replaceAll(qualityPattern, '');
    }

    if (useHls) {
      // استخدام HLS Playlist (يدعم adaptive streaming تلقائياً)
      // HLS يدعم اختيار الجودة تلقائياً حسب سرعة الإنترنت
      return '$cleanUrl/playlist.m3u8';
    } else {
      // استخدام MP4 مباشر بجودة محددة
      return '$cleanUrl/play_${quality}.mp4';
    }
  }

  /// الحصول على HLS Playlist URL للفيديو
  /// HLS يدعم adaptive streaming تلقائياً واختيار الجودة المناسبة
  ///
  /// [baseVideoUrl] - Base URL للفيديو
  ///
  /// Returns HLS Playlist URL
  static String getHlsPlaylistUrl(String baseVideoUrl) {
    String cleanUrl = baseVideoUrl;
    final qualityPattern = RegExp(r'/play_\d+p\.mp4$|/playlist\.m3u8$');
    if (qualityPattern.hasMatch(cleanUrl)) {
      cleanUrl = cleanUrl.replaceAll(qualityPattern, '');
    }
    return '$cleanUrl/playlist.m3u8';
  }
}
