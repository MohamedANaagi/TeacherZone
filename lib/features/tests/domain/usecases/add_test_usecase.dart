import '../../../../core/errors/exceptions.dart';
import '../entities/test.dart';
import '../repositories/test_repository.dart';

/// Use Case لإضافة اختبار جديد
class AddTestUseCase {
  final TestRepository repository;

  AddTestUseCase(this.repository);

  Future<void> call({
    required String title,
    required String description,
    required String adminCode,
  }) async {
    // التحقق من صحة البيانات
    if (title.trim().isEmpty) {
      throw ValidationException('عنوان الاختبار مطلوب');
    }
    if (description.trim().isEmpty) {
      throw ValidationException('وصف الاختبار مطلوب');
    }
    if (adminCode.trim().isEmpty) {
      throw ValidationException('كود الأدمن مطلوب');
    }

    // إنشاء الاختبار
    final test = Test(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim(),
      description: description.trim(),
      adminCode: adminCode.trim(),
      createdAt: DateTime.now(),
      questionsCount: 0,
    );

    await repository.addTest(test);
  }
}

