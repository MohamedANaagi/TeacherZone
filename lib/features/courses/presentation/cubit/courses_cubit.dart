import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/services/video_progress_service.dart';
import '../../../admin/data/models/course_model.dart';
import 'courses_state.dart';

/// Cubit لإدارة حالة الكورسات
/// يقوم بجلب الكورسات من Firestore عبر AdminRepository
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit() : super(const CoursesState()) {
    // لا نستدعي loadCourses هنا - سيتم استدعاؤها من الشاشة مع الكود
  }

  /// تحميل الكورسات من Firestore
  ///
  /// [userCode] - كود المستخدم (لحساب التقدم من الفيديوهات المشاهدة)
  /// [adminCode] - كود الأدمن (للتصفية - يتم استخدامه مباشرة إذا كان موجوداً)
  ///
  /// الخطوات:
  /// 1. تفعيل حالة التحميل (isLoading = true)
  /// 2. جلب الكورسات من AdminRepository
  /// 3. تحويل CourseModel إلى Map<String, dynamic> مع حساب التقدم من الفيديوهات المشاهدة
  /// 4. تحديث State بالكورسات المحملة
  /// 5. في حالة الخطأ، حفظ رسالة الخطأ في State
  Future<void> loadCourses({String? userCode, String? adminCode}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // استخدام adminCode مباشرة إذا كان موجوداً، وإلا جلب من userCode
      String? finalAdminCode = adminCode;
      if (finalAdminCode == null || finalAdminCode.isEmpty) {
        if (userCode != null && userCode.isNotEmpty) {
          final codeModel = await InjectionContainer.adminRepo.getCodeByCode(userCode);
          finalAdminCode = codeModel?.adminCode;
        }
      }
      
      // جلب الكورسات من Firestore عبر AdminRepository مع تصفية حسب adminCode
      final courseModels = await InjectionContainer.adminRepo.getCourses(adminCode: finalAdminCode);

      // تحويل CourseModel إلى Map<String, dynamic> مع حساب التقدم
      final courses = await Future.wait(
        courseModels.map((course) => _courseModelToMap(course, userCode: userCode)),
      );

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
  /// [userCode] - كود المستخدم (لحساب التقدم من الفيديوهات المشاهدة)
  ///
  /// يعيد Map يحتوي على جميع بيانات الكورس مع إضافة:
  /// - progress: نسبة التقدم المحسوبة من الفيديوهات المشاهدة
  /// - image: 'math' (افتراضي)
  /// - color: لون من AppColors
  Future<Map<String, dynamic>> _courseModelToMap(
    CourseModel course, {
    String? userCode,
  }) async {
    // توزيع الألوان بشكل دوري
    final colors = [
      AppColors.courseColor.value,
      AppColors.courseColorLight.value,
      AppColors.courseColorDark.value,
    ];
    final colorIndex = int.tryParse(course.id) ?? 0;
    final color = colors[colorIndex % colors.length];

    // حساب التقدم من الفيديوهات المشاهدة
    int progress = 0;
    if (userCode != null && userCode.isNotEmpty) {
      try {
        // جلب الفيديوهات المشاهدة للكورس
        final watchedVideos = await VideoProgressService.getWatchedVideosForCourse(
          code: userCode,
          courseId: course.id,
        );

        // جلب adminCode من الكورس
        final adminCode = course.adminCode;
        
        // جلب عدد الفيديوهات الإجمالي
        final videoModels = await InjectionContainer.adminRepo
            .getVideosByCourseId(course.id, adminCode: adminCode);
        final totalVideos = videoModels.length;

        // حساب نسبة التقدم
        if (totalVideos > 0) {
          progress = ((watchedVideos.length / totalVideos) * 100).round();
        }
        
        debugPrint(
          'تم حساب التقدم للكورس ${course.id}: $progress% (${watchedVideos.length}/$totalVideos)',
        );
      } catch (e) {
        debugPrint('خطأ في حساب التقدم للكورس ${course.id}: $e');
        progress = 0;
      }
    }

    return {
      'id': course.id,
      'title': course.title,
      'description': course.description,
      'instructor': course.instructor,
      'lessonsCount': course.lessonsCount,
      'duration': course.duration,
      'progress': progress,
      'image': 'math', // TODO: يمكن إضافة image في CourseModel
      'color': color,
    };
  }

  /// تحديث تقدم الكورس
  ///
  /// [courseId] - معرف الكورس المراد تحديث تقدمه
  /// [userCode] - كود المستخدم (لحساب التقدم من الفيديوهات المشاهدة)
  ///
  /// يعيد حساب التقدم من الفيديوهات المشاهدة المحفوظة ويحدث State
  Future<void> updateCourseProgress(String courseId, {String? userCode}) async {
    if (userCode == null || userCode.isEmpty) {
      return;
    }

    try {
      // جلب الفيديوهات المشاهدة للكورس
      final watchedVideos = await VideoProgressService.getWatchedVideosForCourse(
        code: userCode,
        courseId: courseId,
      );

      // جلب الكورس للحصول على adminCode
      final courses = await InjectionContainer.adminRepo.getCourses();
      final course = courses.firstWhere((c) => c.id == courseId, orElse: () => throw Exception('الكورس غير موجود'));
      final adminCode = course.adminCode;
      
      // جلب عدد الفيديوهات الإجمالي
      final videoModels = await InjectionContainer.adminRepo
          .getVideosByCourseId(courseId, adminCode: adminCode);
      final totalVideos = videoModels.length;

      // حساب نسبة التقدم
      int progress = 0;
      if (totalVideos > 0) {
        progress = ((watchedVideos.length / totalVideos) * 100).round();
      }

      // تحديث التقدم في State
      final updatedCourses = state.courses.map((course) {
        if (course['id'] == courseId) {
          return {...course, 'progress': progress};
        }
        return course;
      }).toList();

      emit(state.copyWith(courses: updatedCourses));
      
      debugPrint(
        'تم تحديث التقدم للكورس $courseId: $progress% (${watchedVideos.length}/$totalVideos)',
      );
    } catch (e) {
      debugPrint('خطأ في تحديث التقدم للكورس $courseId: $e');
    }
  }
}
