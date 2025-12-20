import 'package:equatable/equatable.dart';

/// حالة الكورسات
/// تحتفظ بقائمة الكورسات، حالة التحميل، ورسالة الخطأ (إن وجدت)
class CoursesState extends Equatable {
  /// قائمة الكورسات
  /// كل كورس هو Map يحتوي على: id, title, description, instructor,
  /// lessonsCount, duration, progress, image, color
  final List<Map<String, dynamic>> courses;

  /// حالة التحميل - true أثناء جلب البيانات من Firestore
  final bool isLoading;

  /// رسالة الخطأ (إن وجدت)
  final String? error;

  const CoursesState({
    this.courses = const [],
    this.isLoading = false,
    this.error,
  });

  /// نسخ الحالة مع تحديث القيم المطلوبة
  ///
  /// [courses] - قائمة جديدة من الكورسات (اختياري)
  /// [isLoading] - حالة التحميل الجديدة (اختياري)
  /// [error] - رسالة الخطأ الجديدة (اختياري)
  /// [clearError] - إذا كانت true، يتم مسح رسالة الخطأ
  CoursesState copyWith({
    List<Map<String, dynamic>>? courses,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CoursesState(
      courses: courses ?? this.courses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [courses, isLoading, error];
}
