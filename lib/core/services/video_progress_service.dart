import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../di/injection_container.dart';

/// خدمة لحفظ وتحميل حالة مشاهدة الفيديوهات
/// تُحفظ في SharedPreferences (للاستخدام بدون إنترنت) و Firestore (للمزامنة بين الأجهزة)
/// تُحفظ بناءً على الكود والكورس والفيديو
class VideoProgressService {
  /// الحصول على مفتاح الحفظ بناءً على الكود والكورس والفيديو
  static String _getKey(String code, String courseId, String videoId) {
    return 'video_watched_${code}_${courseId}_$videoId';
  }

  /// حفظ حالة مشاهدة الفيديو
  ///
  /// [code] كود المستخدم
  /// [courseId] معرف الكورس
  /// [videoId] معرف الفيديو
  /// [isWatched] حالة المشاهدة
  ///
  /// يحفظ في SharedPreferences (للاستخدام بدون إنترنت) و Firestore (للمزامنة بين الأجهزة)
  static Future<void> saveVideoWatchedStatus({
    required String code,
    required String courseId,
    required String videoId,
    required bool isWatched,
  }) async {
    try {
      // حفظ محلياً في SharedPreferences (للاستخدام بدون إنترنت)
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(code, courseId, videoId);
      
      if (isWatched) {
        await prefs.setBool(key, true);
        debugPrint('تم حفظ حالة المشاهدة محلياً: $code/$courseId/$videoId');
      } else {
        await prefs.remove(key);
        debugPrint('تم حذف حالة المشاهدة محلياً: $code/$courseId/$videoId');
      }

      // حفظ في Firestore (للمزامنة بين الأجهزة)
      try {
        await InjectionContainer.adminRepo.saveVideoProgress(
          code: code,
          courseId: courseId,
          videoId: videoId,
          isWatched: isWatched,
        );
        debugPrint('تم حفظ حالة المشاهدة في Firestore: $code/$courseId/$videoId');
      } catch (e) {
        // إذا فشل الحفظ في Firestore، نستمر لأن البيانات محفوظة محلياً
        debugPrint('تحذير: فشل حفظ حالة المشاهدة في Firestore: $e');
      }
    } catch (e) {
      debugPrint('خطأ في حفظ حالة المشاهدة: $e');
    }
  }

  /// جلب حالة مشاهدة الفيديو
  ///
  /// [code] كود المستخدم
  /// [courseId] معرف الكورس
  /// [videoId] معرف الفيديو
  /// Returns true إذا كان الفيديو مشاهد، false إذا لم يكن
  static Future<bool> getVideoWatchedStatus({
    required String code,
    required String courseId,
    required String videoId,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getKey(code, courseId, videoId);
      return prefs.getBool(key) ?? false;
    } catch (e) {
      debugPrint('خطأ في جلب حالة المشاهدة: $e');
      return false;
    }
  }

  /// جلب جميع الفيديوهات المشاهدة لكورس معين
  ///
  /// [code] كود المستخدم
  /// [courseId] معرف الكورس
  /// [preferRemote] إذا كان true، يحاول جلب من Firestore أولاً، وإلا يجلب من SharedPreferences
  /// Returns Set من معرفات الفيديوهات المشاهدة
  static Future<Set<String>> getWatchedVideosForCourse({
    required String code,
    required String courseId,
    bool preferRemote = false,
  }) async {
    try {
      Set<String> watchedVideos = {};

      // محاولة جلب من Firestore إذا preferRemote = true
      if (preferRemote) {
        try {
          watchedVideos = await InjectionContainer.adminRepo.getWatchedVideosForCourse(
            code: code,
            courseId: courseId,
          );
          debugPrint('تم جلب ${watchedVideos.length} فيديو مشاهد من Firestore');
          
          // مزامنة مع SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final prefix = 'video_watched_${code}_${courseId}_';
          
          // حذف جميع المفاتيح القديمة لهذا الكورس
          final allKeys = prefs.getKeys();
          for (final key in allKeys) {
            if (key.startsWith(prefix)) {
              await prefs.remove(key);
            }
          }
          
          // حفظ البيانات من Firestore في SharedPreferences
          for (final videoId in watchedVideos) {
            final key = _getKey(code, courseId, videoId);
            await prefs.setBool(key, true);
          }
          
          return watchedVideos;
        } catch (e) {
          debugPrint('تحذير: فشل جلب من Firestore، استخدام البيانات المحلية: $e');
          // الاستمرار في جلب من SharedPreferences
        }
      }

      // جلب من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'video_watched_${code}_${courseId}_';
      
      final allKeys = prefs.getKeys();
      
      for (final key in allKeys) {
        if (key.startsWith(prefix) && prefs.getBool(key) == true) {
          // استخراج videoId من المفتاح
          final videoId = key.substring(prefix.length);
          watchedVideos.add(videoId);
        }
      }
      
      return watchedVideos;
    } catch (e) {
      debugPrint('خطأ في جلب الفيديوهات المشاهدة: $e');
      return {};
    }
  }

  /// حذف جميع حالات المشاهدة لكود معين (عند تسجيل الخروج)
  /// ملاحظة: لا نحذف الحالات لأن المستخدم قد يعود بنفس الكود
  /// يمكن استخدام هذه الدالة فقط عند حذف الكود نهائياً
  static Future<void> clearVideoProgressForCode({required String code}) async {
    try {
      // حذف من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefix = 'video_watched_${code}_';
      
      final allKeys = prefs.getKeys();
      final keysToRemove = allKeys.where((key) => key.startsWith(prefix)).toList();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      
      debugPrint('تم حذف ${keysToRemove.length} حالة مشاهدة محلية للكود: $code');

      // حذف من Firestore
      try {
        await InjectionContainer.adminRepo.clearVideoProgressForCode(code: code);
        debugPrint('تم حذف حالات المشاهدة من Firestore للكود: $code');
      } catch (e) {
        debugPrint('تحذير: فشل حذف حالات المشاهدة من Firestore: $e');
      }
    } catch (e) {
      debugPrint('خطأ في حذف حالات المشاهدة: $e');
    }
  }

  /// مزامنة تقدم الفيديوهات من Firestore إلى SharedPreferences
  ///
  /// [code] كود المستخدم
  /// [adminCode] كود الأدمن (اختياري، لتصفية الكورسات)
  ///
  /// تجلب جميع الفيديوهات المشاهدة من Firestore وتحفظها محلياً
  /// تستخدم عند تسجيل الدخول لمزامنة التقدم من الأجهزة الأخرى
  static Future<void> syncProgressFromFirestore({
    required String code,
    String? adminCode,
  }) async {
    try {
      debugPrint('بدء مزامنة تقدم الفيديوهات من Firestore للكود: $code');
      
      // جلب الكورسات (مصفاة حسب adminCode إذا كان موجوداً)
      final courses = await InjectionContainer.adminRepo.getCourses(adminCode: adminCode);
      
      if (courses.isEmpty) {
        debugPrint('لا توجد كورسات للمزامنة');
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      int syncedCount = 0;

      // لكل كورس، جلب الفيديوهات المشاهدة من Firestore
      for (final course in courses) {
        try {
          final watchedVideos = await InjectionContainer.adminRepo.getWatchedVideosForCourse(
            code: code,
            courseId: course.id,
          );

          // حفظ في SharedPreferences
          for (final videoId in watchedVideos) {
            final key = _getKey(code, course.id, videoId);
            await prefs.setBool(key, true);
            syncedCount++;
          }
        } catch (e) {
          debugPrint('تحذير: فشل مزامنة تقدم الكورس ${course.id}: $e');
        }
      }

      debugPrint('✅ تمت مزامنة $syncedCount فيديو من Firestore للكود: $code');
    } catch (e) {
      debugPrint('خطأ في مزامنة تقدم الفيديوهات من Firestore: $e');
    }
  }
}

