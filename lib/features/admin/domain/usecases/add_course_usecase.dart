import '../../../../core/errors/exceptions.dart';
import '../../data/models/course_model.dart';
import '../repositories/admin_repository.dart';

class AddCourseUseCase {
  final AdminRepository repository;

  AddCourseUseCase(this.repository);

  Future<void> call({
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

    final courseModel = CourseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      instructor: instructor.trim(),
      duration: duration.trim(),
      lessonsCount: 0,
      createdAt: DateTime.now(),
    );

    await repository.addCourse(courseModel);
  }
}
