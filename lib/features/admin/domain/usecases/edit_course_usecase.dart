import '../../../../core/errors/exceptions.dart';
import '../../data/models/course_model.dart';
import '../repositories/admin_repository.dart';

class EditCourseUseCase {
  final AdminRepository repository;

  EditCourseUseCase(this.repository);

  Future<void> call({
    required String courseId,
    required String title,
    required String description,
    required String instructor,
    required String duration,
  }) async {
    // Validation
    if (title.trim().isEmpty) {
      throw ValidationException('عنوان الكورس مطلوب');
    }
    if (description.trim().isEmpty) {
      throw ValidationException('وصف الكورس مطلوب');
    }
    if (instructor.trim().isEmpty) {
      throw ValidationException('اسم المدرب مطلوب');
    }
    if (duration.trim().isEmpty) {
      throw ValidationException('مدة الكورس مطلوبة');
    }

    // جلب الكورس الحالي للحصول على البيانات التي لا تتغير
    final courses = await repository.getCourses();
    final existingCourse = courses.firstWhere(
      (course) => course.id == courseId,
      orElse: () => throw ValidationException('الكورس غير موجود'),
    );

    // إنشاء CourseModel محدث مع الحفاظ على البيانات الأصلية
    final updatedCourseModel = CourseModel(
      id: courseId,
      title: title.trim(),
      description: description.trim(),
      instructor: instructor.trim(),
      duration: duration.trim(),
      lessonsCount: existingCourse.lessonsCount,
      createdAt: existingCourse.createdAt,
      adminCode: existingCourse.adminCode,
    );

    await repository.updateCourse(updatedCourseModel);
  }
}

