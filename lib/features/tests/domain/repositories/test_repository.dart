import '../entities/question.dart';
import '../entities/test.dart';
import '../entities/test_result.dart';

/// واجهة مستودع الاختبارات - Domain Layer
abstract class TestRepository {
  // Tests
  Future<void> addTest(Test test);
  Future<List<Test>> getTests({String? adminCode});
  Future<Test?> getTestById(String testId);
  Future<void> deleteTest(String testId);
  Future<void> updateTest(Test test);

  // Questions
  Future<void> addQuestion(Question question);
  Future<List<Question>> getQuestionsByTestId(String testId);
  Future<void> deleteQuestion(String questionId);
  Future<void> updateQuestion(Question question);
  Future<void> updateQuestionsCountForTest(String testId);

  // Test Results
  Future<void> saveTestResult(TestResult result);
  Future<List<TestResult>> getTestResultsByStudentCode(String studentCode);
  Future<List<TestResult>> getTestResultsByTestId(String testId);
  Future<TestResult?> getTestResult(String resultId);
}

