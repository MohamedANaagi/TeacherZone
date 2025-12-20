import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../admin/data/models/course_model.dart';
import 'courses_state.dart';

/// Cubit لإدارة حالة الكورسات
/// يقوم بجلب الكورسات من Firestore عبر AdminRepository
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit() : super(const CoursesState()) {
    loadCourses();
  }

  /// تحميل الكورسات من Firestore
  ///
  /// الخطوات:
  /// 1. تفعيل حالة التحميل (isLoading = true)
  /// 2. جلب الكورسات من AdminRepository
  /// 3. تحويل CourseModel إلى Map<String, dynamic> للتوافق مع State
  /// 4. إضافة معلومات إضافية مثل progress و color و image
  /// 5. تحديث State بالكورسات المحملة
  /// 6. في حالة الخطأ، حفظ رسالة الخطأ في State
  Future<void> loadCourses() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // جلب الكورسات من Firestore عبر AdminRepository
      final courseModels = await InjectionContainer.adminRepo.getCourses();

      // تحويل CourseModel إلى Map<String, dynamic> مع إضافة معلومات إضافية
      final courses = courseModels
          .map((course) => _courseModelToMap(course))
          .toList();

      emit(state.copyWith(courses: courses, isLoading: false));
    } on ServerException catch (e) {
      debugPrint('خطأ في تحميل الكورسات: $e');
      emit(state.copyWith(isLoading: false, error: e.message));
    } catch (e) {
      debugPrint('خطأ غير متوقع في تحميل الكورسات: $e');
      emit(
        state.copyWith(isLoading: false, error: 'حدث خطأ أثناء تحميل الكورسات'),
      );
    }
  }

  /// تحويل CourseModel إلى Map<String, dynamic>
  ///
  /// [course] - CourseModel المراد تحويله
  ///
  /// يعيد Map يحتوي على جميع بيانات الكورس مع إضافة:
  /// - progress: 0 (افتراضي)
  /// - image: 'math' (افتراضي)
  /// - color: لون من AppColors
  Map<String, dynamic> _courseModelToMap(CourseModel course) {
    // توزيع الألوان بشكل دوري
    final colors = [
      AppColors.courseColor.value,
      AppColors.courseColorLight.value,
      AppColors.courseColorDark.value,
    ];
    final colorIndex = int.tryParse(course.id) ?? 0;
    final color = colors[colorIndex % colors.length];

    return {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'instructor': course.instructor,
      'lessonsCount': course.lessonsCount,
      'duration': course.duration,
      'progress': 0, // TODO: يمكن جلب progress من Firestore في المستقبل
      'image': 'math', // TODO: يمكن إضافة image في CourseModel
      'color': color,
    };
  }

  /// تحديث تقدم الكورس
  ///
  /// [courseId] - معرف الكورس المراد تحديث تقدمه
  /// [progress] - نسبة التقدم (0-100)
  ///
  /// يحدث حالة التقدم للكورس في State (محلياً فقط)
  /// TODO: يمكن حفظ progress في Firestore في المستقبل
  void updateCourseProgress(String courseId, int progress) {
    final updatedCourses = state.courses.map((course) {
      if (course['id'] == courseId) {
        return {...course, 'progress': progress};
      }
      return course;
    }).toList();

    emit(state.copyWith(courses: updatedCourses));
  }
}
