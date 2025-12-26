import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

/// Timeout للطلبات HTTP (بالثواني)
/// للويب: نستخدم timeout أطول لأن الملفات قد تكون كبيرة
const Duration _httpTimeout = Duration(minutes: 10);
const Duration _httpConnectTimeout = Duration(seconds: 30);

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
  /// [videoBytes] - bytes الفيديو (للويب - للملفات الصغيرة فقط)
  /// [videoStream] - Stream للفيديو (للويب - للملفات الكبيرة)
  /// [fileSize] - حجم الملف بالبايت (مطلوب عند استخدام Stream)
  /// [fileName] - اسم الملف (مطلوب)
  /// [onProgress] - callback لتتبع التقدم (0.0 إلى 1.0)
  ///
  /// Returns URL الفيديو بعد الرفع
  /// Throws Exception في حالة فشل الرفع
  static Future<String> uploadVideo({
    File? videoFile,
    Uint8List? videoBytes,
    Stream<List<int>>? videoStream,
    int? fileSize,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    try {
      if (fileName.isEmpty) {
        throw Exception('اسم الملف مطلوب');
      }

      // تحديد حجم الملف وطريقة القراءة
      int? actualFileSize;
      Stream<List<int>>? uploadStream;

      if (kIsWeb) {
        // للويب: استخدام Stream إذا كان متوفراً (للملفات الكبيرة)
        if (videoStream != null && fileSize != null) {
          uploadStream = videoStream;
          actualFileSize = fileSize;
          if (kDebugMode) {
            debugPrint('🚀 بدء رفع الفيديو إلى Bunny Stream (Stream Mode)');
            debugPrint(
              '📦 حجم الملف: ${(actualFileSize / 1024 / 1024).toStringAsFixed(2)} MB',
            );
          }
        } else if (videoBytes != null) {
          // للملفات الصغيرة: استخدام bytes مباشرة
          actualFileSize = videoBytes.length;
          uploadStream = Stream.value(videoBytes);
          if (kDebugMode) {
            debugPrint('🚀 بدء رفع الفيديو إلى Bunny Stream (Bytes Mode)');
            debugPrint(
              '📦 حجم الملف: ${(actualFileSize / 1024 / 1024).toStringAsFixed(2)} MB',
            );
          }
        } else {
          throw Exception('يجب توفير videoBytes أو videoStream للويب');
        }
      } else {
        // لـ iOS و Android: استخدام Stream من File
        if (videoFile == null) {
          throw Exception('يجب توفير videoFile لـ iOS و Android');
        }
        actualFileSize = await videoFile.length();
        uploadStream = videoFile.openRead();
        if (kDebugMode) {
          debugPrint('🚀 بدء رفع الفيديو إلى Bunny Stream (File Stream Mode)');
          debugPrint(
            '📦 حجم الملف: ${(actualFileSize / 1024 / 1024).toStringAsFixed(2)} MB',
          );
        }
      }

      // الخطوة 1: إنشاء فيديو جديد في Bunny Stream
      // استخدام libraryId كرقم في الـ URL
      final createVideoUrl = '$_streamBaseUrl/library/$_streamLibraryId/videos';
      if (kDebugMode) {
        debugPrint('🔗 Create Video URL: $createVideoUrl');
        // لا نطبع Library ID في production
      }

      final createResponse = await http
          .post(
            Uri.parse(createVideoUrl),
            headers: {
              'AccessKey': _streamApiKey,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'title': path.basenameWithoutExtension(fileName),
            }),
          )
          .timeout(
            _httpConnectTimeout,
            onTimeout: () {
              throw Exception(
                'انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
              );
            },
          );

      if (kDebugMode) {
        debugPrint('📤 Create Response Status: ${createResponse.statusCode}');
        // لا نطبع Response Body في production لأنه قد يحتوي على معلومات حساسة
        debugPrint('📤 Create Response: Success');
      }

      if (createResponse.statusCode != 200) {
        debugPrint(
          '❌ فشل إنشاء فيديو في Bunny Stream: ${createResponse.statusCode}',
        );
        if (kDebugMode) {
          debugPrint('Response: ${createResponse.body}');
        }
        throw Exception(
          'فشل إنشاء فيديو: ${createResponse.statusCode} - ${createResponse.body}',
        );
      }

      final videoData = jsonDecode(createResponse.body) as Map<String, dynamic>;
      if (kDebugMode) {
        debugPrint('📋 Video Data Response: Video created successfully');
      }

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

      if (kDebugMode) {
        debugPrint('✅ تم إنشاء فيديو في Bunny Stream بنجاح');
      }

      // الخطوة 2: رفع ملف الفيديو
      final uploadUrl =
          '$_streamBaseUrl/library/$_streamLibraryId/videos/$videoId';

      if (kDebugMode) {
        debugPrint('📤 بدء رفع ملف الفيديو...');
        debugPrint('🔗 Upload URL: [Uploading...]');
        debugPrint(
          '📦 حجم البيانات: ${(actualFileSize / 1024 / 1024).toStringAsFixed(2)} MB',
        );
      }

      // استخدام StreamedRequest للرفع المتدرج (للملفات الكبيرة)
      final request = http.StreamedRequest('PUT', Uri.parse(uploadUrl));
      request.headers.addAll({
        'AccessKey': _streamApiKey,
        'Content-Type': 'application/octet-stream',
        'Content-Length': actualFileSize.toString(),
      });

      // تتبع التقدم
      int bytesSent = 0;
      final totalSize = actualFileSize; // حفظ القيمة لتجنب مشاكل null
      bool sinkClosed = false;
      Exception? streamError;
      StreamSubscription<List<int>>? streamSubscription;
      double lastProgressSent =
          -1.0; // لتتبع آخر قيمة تم إرسالها (ابدأ من -1 لضمان التحديث الأول)
      int lastProgressPercent = -1; // لتتبع آخر نسبة مئوية تم إرسالها
      const progressUpdateThreshold = 0.005; // تحديث كل 0.5% على الأقل

      // تقسيم الـ stream إلى chunks صغيرة جداً لتجنب مشاكل الذاكرة في الويب
      const maxChunkSize =
          256 *
          1024; // 256 KB كحد أقصى (حجم صغير جداً لتجنب Array buffer allocation)

      // إنشاء Stream Transformer لتقسيم الـ chunks الكبيرة
      final chunkedStream = uploadStream.expand<List<int>>((chunk) {
        // إذا كان الـ chunk صغيراً، أرسله مباشرة
        if (chunk.length <= maxChunkSize) {
          return [chunk];
        }

        // تقسيم الـ chunk الكبير إلى أجزاء صغيرة
        // استخدام طريقة لا تنسخ البيانات في الذاكرة
        final chunks = <List<int>>[];
        int offset = 0;
        while (offset < chunk.length) {
          final end = (offset + maxChunkSize < chunk.length)
              ? offset + maxChunkSize
              : chunk.length;

          // إنشاء sublist - في الويب، هذا ينسخ البيانات لكن بحجم صغير (256 KB)
          chunks.add(chunk.sublist(offset, end));
          offset = end;
        }
        return chunks;
      });

      streamSubscription = chunkedStream.listen(
        (chunk) {
          try {
            // التحقق من أن الـ sink لم يُغلق
            if (sinkClosed) {
              debugPrint('⚠️ تم إغلاق الـ sink، توقف إرسال البيانات');
              streamSubscription?.cancel();
              return;
            }

            // إرسال الـ chunk مباشرة (لأنه الآن صغير - 256 KB كحد أقصى)
            try {
              request.sink.add(chunk);
              bytesSent += chunk.length;

              // حساب النسبة المئوية وإرسالها عبر callback
              // تحديث التقدم بشكل تدريجي
              if (onProgress != null && totalSize > 0) {
                final progress = bytesSent / totalSize;
                // الحد الأقصى للتقدم هو 95% حتى نضمن اكتمال الرفع فعلياً
                // سنرسل 100% فقط بعد استجابة السيرفر
                final maxProgress = 0.95;
                final clampedProgress = progress.clamp(0.0, maxProgress);
                final currentPercent = (clampedProgress * 100).round();

                // تحديث التقدم في الحالات التالية:
                // 1. إذا تغير التقدم بنسبة 0.5% على الأقل
                // 2. إذا تغيرت النسبة المئوية (1% على الأقل)
                // 3. إذا وصلنا إلى 95% (الحد الأقصى قبل اكتمال الرفع)
                final progressDiff = clampedProgress - lastProgressSent;
                final shouldUpdate =
                    progressDiff >= progressUpdateThreshold ||
                    currentPercent != lastProgressPercent ||
                    (bytesSent >= totalSize && clampedProgress >= maxProgress - 0.01);

                if (shouldUpdate) {
                  onProgress(clampedProgress);
                  lastProgressSent = clampedProgress;
                  lastProgressPercent = currentPercent;

                  // طباعة التقدم عند كل تحديث
                  if (kDebugMode) {
                    debugPrint(
                      '📤 التقدم: ${(clampedProgress * 100).toStringAsFixed(1)}% (${(bytesSent / 1024 / 1024).toStringAsFixed(2)} MB / ${(totalSize / 1024 / 1024).toStringAsFixed(2)} MB)',
                    );
                  }
                }
              }
            } catch (e) {
              sinkClosed = true;
              streamError = Exception('خطأ في إرسال chunk: $e');
              debugPrint('❌ خطأ في إرسال chunk: $e');
              streamSubscription?.cancel();
            }
          } catch (e, stackTrace) {
            sinkClosed = true;
            streamError = Exception('خطأ في معالجة chunk: $e');
            debugPrint('❌ خطأ في معالجة chunk: $e');
            debugPrint('Stack trace: $stackTrace');
            streamSubscription?.cancel();
            try {
              request.sink.close();
            } catch (_) {
              // تجاهل الأخطاء عند إغلاق الـ sink
            }
          }
        },
        onDone: () {
          try {
            if (!sinkClosed) {
              request.sink.close();
            }
            // لا نرسل 100% هنا - سننتظر استجابة السيرفر أولاً
            // سيتم إرسال 100% بعد نجاح الرفع
          } catch (e) {
            debugPrint('❌ خطأ في إغلاق الـ sink: $e');
          }
        },
        onError: (error) {
          sinkClosed = true;
          streamError = Exception('خطأ في Stream: $error');
          debugPrint('❌ خطأ في Stream: $error');
          streamSubscription?.cancel();
          try {
            request.sink.close();
          } catch (e) {
            debugPrint('❌ خطأ في إغلاق الـ sink بعد الخطأ: $e');
          }
        },
        cancelOnError: true,
      );

      // التحقق من وجود خطأ في Stream قبل الإرسال
      if (streamError != null) {
        throw streamError!;
      }

      // إرسال الطلب مع timeout أطول للملفات الكبيرة
      final streamedResponse = await request.send().timeout(
        _httpTimeout,
        onTimeout: () {
          sinkClosed = true;
          try {
            request.sink.close();
          } catch (_) {
            // تجاهل الأخطاء عند إغلاق الـ sink
          }
          throw Exception(
            'انتهت مهلة رفع الفيديو. الملف كبير جداً أو اتصال الإنترنت بطيء. يرجى المحاولة مرة أخرى.',
          );
        },
      );

      // التحقق من وجود خطأ في Stream بعد الإرسال
      if (streamError != null) {
        throw streamError!;
      }

      // قراءة الاستجابة
      final uploadResponse = await http.Response.fromStream(streamedResponse);

      if (uploadResponse.statusCode == 200 ||
          uploadResponse.statusCode == 201) {
        // إرسال 100% فقط بعد نجاح الرفع على السيرفر
        if (onProgress != null) {
          // إرسال 99% أولاً كإشارة إلى اكتمال الإرسال
          onProgress(0.99);
          // ثم إرسال 100% بعد تأكيد النجاح
          await Future.delayed(const Duration(milliseconds: 100));
          onProgress(1.0);
        }

        // بناء Stream URL للفيديو (بدون جودة محددة - سيتم تحديدها في المشغل)
        // نرجع base URL بدون جودة، وسيتم إضافة الجودة في مشغل الفيديو
        final videoUrl = '$_streamCdnUrl/$videoId';
        if (kDebugMode) {
          debugPrint('✅ تم رفع الفيديو بنجاح إلى Bunny Stream');
        }
        return videoUrl;
      } else {
        if (kDebugMode) {
          debugPrint('❌ فشل رفع الفيديو: ${uploadResponse.statusCode}');
          debugPrint('Response: ${uploadResponse.body}');
        }
        throw Exception(
          'فشل رفع الفيديو: ${uploadResponse.statusCode} - ${uploadResponse.body}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ خطأ في الاتصال (ClientException): $e');
      throw Exception(
        'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
      );
    } on FormatException catch (e) {
      debugPrint('❌ خطأ في تنسيق البيانات (FormatException): $e');
      throw Exception('خطأ في تنسيق البيانات. يرجى المحاولة مرة أخرى.');
    } on Exception catch (e) {
      debugPrint('❌ خطأ في رفع الفيديو: $e');
      // إذا كانت الرسالة تحتوي على "انتهت مهلة"، نعيدها كما هي
      if (e.toString().contains('انتهت مهلة')) {
        rethrow;
      }
      throw Exception(
        'فشل رفع الفيديو: ${e.toString()}. يرجى المحاولة مرة أخرى.',
      );
    } catch (e) {
      debugPrint('❌ خطأ غير متوقع في رفع الفيديو: $e');
      throw Exception(
        'حدث خطأ غير متوقع أثناء رفع الفيديو. يرجى المحاولة مرة أخرى.',
      );
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

      if (kDebugMode) {
        debugPrint('🚀 بدء رفع الصورة إلى Bunny Storage');
        debugPrint(
          '📦 حجم الملف: ${(fileBytes.length / 1024).toStringAsFixed(2)} KB',
        );
      }

      // رفع الملف
      // للويب: استخدام timeout أطول للملفات الكبيرة
      final response = await http
          .put(
            Uri.parse(uploadUrl),
            headers: {
              'AccessKey': _storageApiKey,
              'Content-Type': 'application/octet-stream',
            },
            body: fileBytes,
          )
          .timeout(
            _httpTimeout,
            onTimeout: () {
              throw Exception(
                'انتهت مهلة رفع الصورة. الملف كبير جداً أو اتصال الإنترنت بطيء. يرجى المحاولة مرة أخرى.',
              );
            },
          );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // بناء CDN URL
        final imageUrl = '$_cdnUrl/$fileName';
        if (kDebugMode) {
          debugPrint('✅ تم رفع الصورة بنجاح');
        }
        return imageUrl;
      } else {
        if (kDebugMode) {
          debugPrint('❌ فشل رفع الصورة: ${response.statusCode}');
          debugPrint('Response: ${response.body}');
        }
        throw Exception(
          'فشل رفع الصورة: ${response.statusCode} - ${response.body}',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('❌ خطأ في الاتصال (ClientException): $e');
      throw Exception(
        'فشل الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
      );
    } on FormatException catch (e) {
      debugPrint('❌ خطأ في تنسيق البيانات (FormatException): $e');
      throw Exception('خطأ في تنسيق البيانات. يرجى المحاولة مرة أخرى.');
    } on Exception catch (e) {
      debugPrint('❌ خطأ في رفع الصورة: $e');
      // إذا كانت الرسالة تحتوي على "انتهت مهلة"، نعيدها كما هي
      if (e.toString().contains('انتهت مهلة')) {
        rethrow;
      }
      throw Exception(
        'فشل رفع الصورة: ${e.toString()}. يرجى المحاولة مرة أخرى.',
      );
    } catch (e) {
      debugPrint('❌ خطأ غير متوقع في رفع الصورة: $e');
      throw Exception(
        'حدث خطأ غير متوقع أثناء رفع الصورة. يرجى المحاولة مرة أخرى.',
      );
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
      if (kDebugMode) {
        debugPrint('🔍 استخراج اسم الملف من URL');
      }
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

  /// الحصول على معلومات الفيديو من Bunny Stream API
  /// يمكن استخدامها للتحقق من حالة الفيديو والحصول على URL صحيح
  ///
  /// [videoId] - ID الفيديو (guid)
  ///
  /// Returns معلومات الفيديو من API
  static Future<Map<String, dynamic>?> getVideoInfo(String videoId) async {
    try {
      // استخراج videoId من URL إذا كان URL كامل
      String actualVideoId = videoId;
      if (videoId.contains('/')) {
        final uri = Uri.parse(videoId);
        final pathParts = uri.path.split('/');
        if (pathParts.isNotEmpty) {
          // الحصول على آخر جزء من المسار (videoId)
          actualVideoId = pathParts.last;
        }
      }

      final getVideoUrl =
          '$_streamBaseUrl/library/$_streamLibraryId/videos/$actualVideoId';

      final response = await http.get(
        Uri.parse(getVideoUrl),
        headers: {'AccessKey': _streamApiKey},
      );

      if (response.statusCode == 200) {
        final videoData = jsonDecode(response.body) as Map<String, dynamic>;
        debugPrint('✅ تم جلب معلومات الفيديو بنجاح');
        return videoData;
      } else {
        debugPrint('❌ فشل جلب معلومات الفيديو: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب معلومات الفيديو: $e');
      return null;
    }
  }

  /// التحقق من أن الفيديو جاهز للتشغيل في Bunny Stream
  ///
  /// [videoId] - ID الفيديو (guid أو URL كامل)
  ///
  /// Returns true إذا كان الفيديو جاهزاً (encoded)، false إذا لم يكن جاهزاً بعد
  static Future<bool> isVideoReady(String videoId) async {
    try {
      final videoInfo = await getVideoInfo(videoId);
      if (videoInfo == null) {
        return false;
      }

      // التحقق من حالة الفيديو
      // في Bunny Stream، الحالات المحتملة:
      // 0 = Created, 1 = Uploading, 2 = Processing, 3 = Finished, 4 = Error, 5 = QuotaExceeded
      final status = videoInfo['status'] as int?;
      final isReady = status == 3; // Finished

      if (kDebugMode) {
        debugPrint('📹 حالة الفيديو: $status (${isReady ? "جاهز" : "غير جاهز بعد"})');
      }

      return isReady;
    } catch (e) {
      debugPrint('❌ خطأ في التحقق من جاهزية الفيديو: $e');
      return false;
    }
  }
}
