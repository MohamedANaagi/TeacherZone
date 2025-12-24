import '../../../../core/errors/exceptions.dart';
import '../entities/question.dart';
import '../repositories/test_repository.dart';

/// Use Case لإضافة سؤال جديد للاختبار
class AddQuestionUseCase {
  final TestRepository repository;

  AddQuestionUseCase(this.repository);

  Future<void> call({
    required String testId,
    required String questionText,
    String? imageUrl,
    required List<String> options,
    required int correctAnswerIndex,
    int? order,
  }) async {
    // التحقق من صحة البيانات
    if (questionText.trim().isEmpty && (imageUrl == null || imageUrl.isEmpty)) {
      throw ValidationException('يجب إدخال نص السؤال أو رفع صورة');
    }
    if (options.length < 2) {
      throw ValidationException('يجب أن يحتوي السؤال على خيارين على الأقل');
    }
    if (correctAnswerIndex < 0 || correctAnswerIndex >= options.length) {
      throw ValidationException('فهرس الإجابة الصحيحة غير صحيح');
    }

    // التحقق من عدم وجود خيارات فارغة
    for (var option in options) {
      if (option.trim().isEmpty) {
        throw ValidationException('لا يمكن أن تكون الخيارات فارغة');
      }
    }

    // الحصول على عدد الأسئلة الحالي لتحديد الترتيب
    final existingQuestions = await repository.getQuestionsByTestId(testId);
    final questionOrder = order ?? existingQuestions.length;

    // إنشاء السؤال
    final question = Question(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: testId,
      questionText: questionText.trim(),
      imageUrl: imageUrl?.trim().isEmpty == true ? null : imageUrl?.trim(),
      options: options.map((e) => e.trim()).toList(),
      correctAnswerIndex: correctAnswerIndex,
      order: questionOrder,
    );

    await repository.addQuestion(question);
    
    // تحديث عدد الأسئلة في الاختبار
    await repository.updateQuestionsCountForTest(testId);
  }
}

