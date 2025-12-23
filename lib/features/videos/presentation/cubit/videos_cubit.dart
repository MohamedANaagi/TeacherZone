import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/video_progress_service.dart';
import '../../../admin/data/models/video_model.dart';
import 'videos_state.dart';

/// Cubit لإدارة حالة الفيديوهات
/// يقوم بجلب الفيديوهات من Firestore عبر AdminRepository
class VideosCubit extends Cubit<VideosState> {
  VideosCubit() : super(const VideosState());

  /// تحميل فيديوهات الكورس من Firestore
  ///
  /// [courseId] - معرف الكورس المراد جلب فيديوهاته
  /// [userCode] - كود المستخدم (لتحميل حالة المشاهدة المحفوظة)
  /// [adminCode] - كود الأدمن (للتصفية - يتم استخدامه مباشرة إذا كان موجوداً)
  ///
  /// الخطوات:
  /// 1. تفعيل حالة التحميل للكورس المحدد
  /// 2. جلب الفيديوهات من AdminRepository باستخدام courseId
  /// 3. تحويل VideoModel إلى Map<String, dynamic> مع تحميل حالة المشاهدة المحفوظة
  /// 4. تحديث State بالفيديوهات المحملة
  /// 5. في حالة الخطأ، حفظ رسالة الخطأ في State
  Future<void> loadCourseVideos(String courseId, {String? userCode, String? adminCode}) async {
    emit(
      state.copyWith(
        courseId: courseId,
        isLoadingForCourse: true,
        clearError: true,
      ),
    );

    try {
      // استخدام adminCode مباشرة إذا كان موجوداً، وإلا جلب من userCode
      String? finalAdminCode = adminCode;
      if (finalAdminCode == null || finalAdminCode.isEmpty) {
        if (userCode != null && userCode.isNotEmpty) {
          final codeModel = await InjectionContainer.adminRepo.getCodeByCode(userCode);
          finalAdminCode = codeModel?.adminCode;
        }
      }
      
      // جلب الفيديوهات من Firestore عبر AdminRepository مع تصفية حسب adminCode
      final videoModels = await InjectionContainer.adminRepo
          .getVideosByCourseId(courseId, adminCode: finalAdminCode);

      // جلب الفيديوهات المشاهدة المحفوظة (إن وجد كود)
      Set<String> watchedVideos = {};
      if (userCode != null && userCode.isNotEmpty) {
        watchedVideos = await VideoProgressService.getWatchedVideosForCourse(
          code: userCode,
          courseId: courseId,
          preferRemote: true, // تفضيل البيانات من Firestore للمزامنة
        );
        debugPrint('تم تحميل ${watchedVideos.length} فيديو مشاهد للكود: $userCode');
      }

      // تحويل VideoModel إلى Map<String, dynamic> مع إضافة معلومات إضافية
      final videos = await Future.wait(
        videoModels.asMap().entries.map((entry) async {
          final index = entry.key;
          final video = entry.value;
          return await _videoModelToMap(
            video,
            index + 1,
            courseId: courseId,
            userCode: userCode,
            watchedVideos: watchedVideos,
          );
        }),
      );

      emit(
        state.copyWith(
          courseId: courseId,
          isLoadingForCourse: false,
          videosForCourse: videos,
        ),
      );
    } on ServerException catch (e) {
      debugPrint('خطأ في تحميل فيديوهات الكورس $courseId: $e');
      emit(
        state.copyWith(
          courseId: courseId,
          isLoadingForCourse: false,
          errorForCourse: e.message,
        ),
      );
    } catch (e) {
      debugPrint('خطأ غير متوقع في تحميل فيديوهات الكورس $courseId: $e');
      emit(
        state.copyWith(
          courseId: courseId,
          isLoadingForCourse: false,
          errorForCourse: 'حدث خطأ أثناء تحميل الفيديوهات',
        ),
      );
    }
  }

  /// تحويل VideoModel إلى Map<String, dynamic>
  ///
  /// [video] - VideoModel المراد تحويله
  /// [order] - ترتيب الفيديو في القائمة
  /// [courseId] - معرف الكورس
  /// [userCode] - كود المستخدم (لتحميل حالة المشاهدة)
  /// [watchedVideos] - Set من معرفات الفيديوهات المشاهدة
  ///
  /// يعيد Map يحتوي على جميع بيانات الفيديو مع إضافة:
  /// - order: ترتيب الفيديو
  /// - isWatched: حالة المشاهدة المحفوظة (من SharedPreferences)
  /// - hasQuiz: false (افتراضي)
  Future<Map<String, dynamic>> _videoModelToMap(
    VideoModel video,
    int order, {
    required String courseId,
    String? userCode,
    Set<String> watchedVideos = const {},
  }) async {
    // التحقق من حالة المشاهدة المحفوظة
    bool isWatched = false;
    if (userCode != null && userCode.isNotEmpty) {
      // استخدام Set للتحقق السريع
      isWatched = watchedVideos.contains(video.id);
    }

    return {
      'id': video.id,
      'title': video.title,
      'duration': video.duration,
      'url': video.url,
      'description': video.description,
      'order': order,
      'isWatched': isWatched,
      'hasQuiz': false,
    };
  }

  /// تحديث حالة مشاهدة الفيديو
  ///
  /// [courseId] - معرف الكورس
  /// [videoId] - معرف الفيديو المراد تحديث حالته
  /// [isWatched] - حالة المشاهدة (اختياري، إذا لم يتم تمريره يتم toggle الحالة الحالية)
  /// [userCode] - كود المستخدم (لحفظ الحالة في SharedPreferences و Firestore)
  ///
  /// يحدث حالة المشاهدة للفيديو في State ويحفظها في SharedPreferences و Firestore
  Future<void> markVideoAsWatched(
    String courseId,
    String videoId, {
    bool? isWatched,
    String? userCode,
  }) async {
    final videos = state.getVideosForCourse(courseId);
    final updatedVideos = videos.map((video) {
      if (video['id'] == videoId) {
        // إذا لم يتم تمرير isWatched، قم بـ toggle الحالة الحالية
        final currentWatched = video['isWatched'] as bool;
        final newWatched = isWatched ?? !currentWatched;
        
        return {...video, 'isWatched': newWatched};
      }
      return video;
    }).toList();

    // تحديث State أولاً لإظهار التغيير فوراً
    emit(state.copyWith(courseId: courseId, videosForCourse: updatedVideos));
    
    // حفظ الحالة في SharedPreferences و Firestore إذا كان هناك كود
    if (userCode != null && userCode.isNotEmpty) {
      final currentWatched = videos.firstWhere(
        (v) => v['id'] == videoId,
        orElse: () => {'isWatched': false},
      )['isWatched'] as bool;
      final newWatched = isWatched ?? !currentWatched;
      
      // حفظ في SharedPreferences و Firestore (await للتأكد من اكتمال الحفظ)
      await VideoProgressService.saveVideoWatchedStatus(
        code: userCode,
        courseId: courseId,
        videoId: videoId,
        isWatched: newWatched,
      );
      debugPrint('✅ تم حفظ حالة المشاهدة للفيديو $videoId في Firestore');
    }
  }

  /// حساب نسبة التقدم للكورس بناءً على الفيديوهات المشاهدة
  ///
  /// [courseId] - معرف الكورس
  ///
  /// Returns نسبة التقدم من 0 إلى 100
  int calculateCourseProgress(String courseId) {
    final videos = state.getVideosForCourse(courseId);
    if (videos.isEmpty) return 0;

    final watchedCount = videos.where((video) => video['isWatched'] == true).length;
    final totalCount = videos.length;
    
    if (totalCount == 0) return 0;
    
    final progress = (watchedCount / totalCount * 100).round();
    return progress;
  }
}
