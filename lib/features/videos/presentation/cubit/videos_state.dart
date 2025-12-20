import 'package:equatable/equatable.dart';

/// حالة الفيديوهات
/// تحتفظ بالفيديوهات لكل كورس بشكل منفصل، مع حالات التحميل والأخطاء
class VideosState extends Equatable {
  /// فيديوهات كل كورس
  /// المفتاح: courseId (String)
  /// القيمة: قائمة الفيديوهات (كل فيديو هو Map يحتوي على: id, title, duration, url,
  /// description, order, isWatched, hasQuiz)
  final Map<String, List<Map<String, dynamic>>> courseVideos;

  /// حالة التحميل لكل كورس
  /// المفتاح: courseId (String)
  /// القيمة: حالة التحميل (bool)
  final Map<String, bool> isLoading;

  /// رسائل الأخطاء لكل كورس
  /// المفتاح: courseId (String)
  /// القيمة: رسالة الخطأ (String?) - null يعني لا يوجد خطأ
  final Map<String, String?> errors;

  const VideosState({
    this.courseVideos = const {},
    this.isLoading = const {},
    this.errors = const {},
  });

  /// نسخ الحالة مع تحديث القيم المطلوبة
  ///
  /// [courseVideos] - خريطة جديدة للفيديوهات (اختياري)
  /// [isLoading] - خريطة جديدة لحالات التحميل (اختياري)
  /// [errors] - خريطة جديدة للأخطاء (اختياري)
  /// [courseId] - معرف الكورس المراد تحديث حالته
  /// [isLoadingForCourse] - حالة التحميل للكورس المحدد
  /// [errorForCourse] - رسالة الخطأ للكورس المحدد
  /// [videosForCourse] - قائمة الفيديوهات للكورس المحدد
  /// [clearError] - إذا كانت true، يتم مسح رسالة الخطأ للكورس المحدد
  VideosState copyWith({
    Map<String, List<Map<String, dynamic>>>? courseVideos,
    Map<String, bool>? isLoading,
    Map<String, String?>? errors,
    String? courseId,
    bool? isLoadingForCourse,
    String? errorForCourse,
    List<Map<String, dynamic>>? videosForCourse,
    bool clearError = false,
  }) {
    final updatedIsLoading = Map<String, bool>.from(
      isLoading ?? this.isLoading,
    );
    final updatedErrors = Map<String, String?>.from(errors ?? this.errors);
    final updatedCourseVideos = Map<String, List<Map<String, dynamic>>>.from(
      courseVideos ?? this.courseVideos,
    );

    // تحديث حالة التحميل للكورس المحدد
    if (courseId != null && isLoadingForCourse != null) {
      updatedIsLoading[courseId] = isLoadingForCourse;
    }

    // تحديث رسالة الخطأ للكورس المحدد
    if (courseId != null && errorForCourse != null) {
      updatedErrors[courseId] = errorForCourse;
    } else if (clearError && courseId != null) {
      updatedErrors.remove(courseId);
    }

    // تحديث قائمة الفيديوهات للكورس المحدد
    if (courseId != null && videosForCourse != null) {
      updatedCourseVideos[courseId] = videosForCourse;
    }

    return VideosState(
      courseVideos: updatedCourseVideos,
      isLoading: updatedIsLoading,
      errors: updatedErrors,
    );
  }

  /// جلب قائمة الفيديوهات لكورس محدد
  ///
  /// [courseId] - معرف الكورس
  ///
  /// يعيد قائمة الفيديوهات أو قائمة فارغة إذا لم يتم العثور على الكورس
  List<Map<String, dynamic>> getVideosForCourse(String courseId) {
    return courseVideos[courseId] ?? [];
  }

  /// التحقق من حالة التحميل لكورس محدد
  ///
  /// [courseId] - معرف الكورس
  ///
  /// يعيد true إذا كان الكورس في حالة تحميل
  bool isLoadingCourse(String courseId) {
    return isLoading[courseId] ?? false;
  }

  /// جلب رسالة الخطأ لكورس محدد
  ///
  /// [courseId] - معرف الكورس
  ///
  /// يعيد رسالة الخطأ أو null إذا لم يكن هناك خطأ
  String? getErrorForCourse(String courseId) {
    return errors[courseId];
  }

  @override
  List<Object?> get props => [courseVideos, isLoading, errors];
}
