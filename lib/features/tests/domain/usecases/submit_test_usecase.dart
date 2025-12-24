import '../entities/test_result.dart';
import '../repositories/test_repository.dart';

/// Use Case لتسليم الاختبار وحساب النتيجة
class SubmitTestUseCase {
  final TestRepository repository;

  SubmitTestUseCase(this.repository);

  Future<TestResult> call({
    required String testId,
    required String studentCode,
    required Map<String, int> answers, // Map<questionId, selectedAnswerIndex>
  }) async {
    // جلب جميع أسئلة الاختبار
    final questions = await repository.getQuestionsByTestId(testId);

    if (questions.isEmpty) {
      throw Exception('الاختبار لا يحتوي على أسئلة');
    }

    // حساب الإجابات الصحيحة والخاطئة
    int correctAnswers = 0;
    int wrongAnswers = 0;

    for (var question in questions) {
      final selectedIndex = answers[question.id];
      
      if (selectedIndex != null) {
        if (question.isCorrect(selectedIndex)) {
          correctAnswers++;
        } else {
          wrongAnswers++;
        }
      } else {
        // إذا لم يتم اختيار إجابة، تعتبر خاطئة
        wrongAnswers++;
      }
    }

    final totalQuestions = questions.length;
    final score = (correctAnswers / totalQuestions) * 100;

    // إنشاء نتيجة الاختبار
    final result = TestResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      testId: testId,
      studentCode: studentCode,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      wrongAnswers: wrongAnswers,
      score: score,
      completedAt: DateTime.now(),
      answers: answers,
    );

    // حفظ النتيجة
    await repository.saveTestResult(result);

    return result;
  }
}

