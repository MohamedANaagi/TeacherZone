import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../admin/data/models/video_model.dart';
import 'videos_state.dart';

/// Cubit لإدارة حالة الفيديوهات
/// يقوم بجلب الفيديوهات من Firestore عبر AdminRepository
class VideosCubit extends Cubit<VideosState> {
  VideosCubit() : super(const VideosState());

  /// تحميل فيديوهات الكورس من Firestore
  ///
  /// [courseId] - معرف الكورس المراد جلب فيديوهاته
  ///
  /// الخطوات:
  /// 1. تفعيل حالة التحميل للكورس المحدد
  /// 2. جلب الفيديوهات من AdminRepository باستخدام courseId
  /// 3. تحويل VideoModel إلى Map<String, dynamic> للتوافق مع State
  /// 4. إضافة معلومات إضافية مثل isWatched و hasQuiz
  /// 5. تحديث State بالفيديوهات المحملة
  /// 6. في حالة الخطأ، حفظ رسالة الخطأ في State
  Future<void> loadCourseVideos(String courseId) async {
    emit(
      state.copyWith(
        courseId: courseId,
        isLoadingForCourse: true,
        clearError: true,
      ),
    );

    try {
      // جلب الفيديوهات من Firestore عبر AdminRepository
      final videoModels = await InjectionContainer.adminRepo
          .getVideosByCourseId(courseId);

      // تحويل VideoModel إلى Map<String, dynamic> مع إضافة معلومات إضافية
      final videos = videoModels.asMap().entries.map((entry) {
        final index = entry.key;
        final video = entry.value;
        return _videoModelToMap(video, index + 1);
      }).toList();

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
  ///
  /// يعيد Map يحتوي على جميع بيانات الفيديو مع إضافة:
  /// - order: ترتيب الفيديو
  /// - isWatched: false (افتراضي)
  /// - hasQuiz: false (افتراضي) - TODO: يمكن إضافته في VideoModel
  Map<String, dynamic> _videoModelToMap(VideoModel video, int order) {
    return {
      'id': video.id,
      'title': video.title,
      'duration': video.duration,
      'url': video.url,
      'description': video.description,
      'order': order,
      'isWatched':
          false, // TODO: يمكن جلب isWatched من Firestore أو SharedPreferences
      'hasQuiz': false, // TODO: يمكن إضافة hasQuiz في VideoModel
    };
  }

  /// تحديث حالة مشاهدة الفيديو
  ///
  /// [courseId] - معرف الكورس
  /// [videoId] - معرف الفيديو المراد تحديث حالته
  ///
  /// يحدث حالة المشاهدة للفيديو في State (محلياً فقط)
  /// TODO: يمكن حفظ isWatched في Firestore أو SharedPreferences في المستقبل
  void markVideoAsWatched(String courseId, String videoId) {
    final videos = state.getVideosForCourse(courseId);
    final updatedVideos = videos.map((video) {
      if (video['id'] == videoId) {
        return {...video, 'isWatched': true};
      }
      return video;
    }).toList();

    emit(state.copyWith(courseId: courseId, videosForCourse: updatedVideos));
  }
}
