import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/test.dart';
import '../../domain/entities/test_result.dart';
import '../../domain/repositories/test_repository.dart';
import '../datasources/test_remote_datasource.dart';
import '../models/question_model.dart';
import '../models/test_model.dart';
import '../models/test_result_model.dart';

/// تطبيق مستودع الاختبارات - Data Layer
class TestRepositoryImpl implements TestRepository {
  final TestRemoteDataSource remoteDataSource;

  TestRepositoryImpl({required this.remoteDataSource});

  // ==================== Tests ====================

  @override
  Future<void> addTest(Test test) async {
    try {
      final testModel = TestModel.fromEntity(test);
      await remoteDataSource.addTest(testModel);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل إضافة الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<List<Test>> getTests({String? adminCode}) async {
    try {
      final tests = await remoteDataSource.getTests(adminCode: adminCode);
      return tests;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل جلب الاختبارات: ${e.toString()}');
    }
  }

  @override
  Future<Test?> getTestById(String testId) async {
    try {
      return await remoteDataSource.getTestById(testId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل جلب الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTest(String testId) async {
    try {
      await remoteDataSource.deleteTest(testId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل حذف الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<void> updateTest(Test test) async {
    try {
      final testModel = TestModel.fromEntity(test);
      await remoteDataSource.updateTest(testModel);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل تحديث الاختبار: ${e.toString()}');
    }
  }

  // ==================== Questions ====================

  @override
  Future<void> addQuestion(Question question) async {
    try {
      final questionModel = QuestionModel.fromEntity(question);
      await remoteDataSource.addQuestion(questionModel);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل إضافة السؤال: ${e.toString()}');
    }
  }

  @override
  Future<List<Question>> getQuestionsByTestId(String testId) async {
    try {
      final questions = await remoteDataSource.getQuestionsByTestId(testId);
      return questions;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل جلب الأسئلة: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteQuestion(String questionId) async {
    try {
      await remoteDataSource.deleteQuestion(questionId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل حذف السؤال: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuestion(Question question) async {
    try {
      final questionModel = QuestionModel.fromEntity(question);
      await remoteDataSource.updateQuestion(questionModel);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل تحديث السؤال: ${e.toString()}');
    }
  }

  @override
  Future<void> updateQuestionsCountForTest(String testId) async {
    try {
      await remoteDataSource.updateQuestionsCountForTest(testId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل تحديث عدد الأسئلة: ${e.toString()}');
    }
  }

  // ==================== Test Results ====================

  @override
  Future<void> saveTestResult(TestResult result) async {
    try {
      final resultModel = TestResultModel.fromEntity(result);
      await remoteDataSource.saveTestResult(resultModel);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل حفظ نتيجة الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<List<TestResult>> getTestResultsByStudentCode(String studentCode) async {
    try {
      final results =
          await remoteDataSource.getTestResultsByStudentCode(studentCode);
      return results;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل جلب نتائج الاختبارات: ${e.toString()}');
    }
  }

  @override
  Future<List<TestResult>> getTestResultsByTestId(String testId) async {
    try {
      final results = await remoteDataSource.getTestResultsByTestId(testId);
      return results;
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل جلب نتائج الاختبار: ${e.toString()}');
    }
  }

  @override
  Future<TestResult?> getTestResult(String resultId) async {
    try {
      return await remoteDataSource.getTestResult(resultId);
    } catch (e) {
      if (e is ServerException) {
        rethrow;
      }
      throw ServerException('فشل جلب نتيجة الاختبار: ${e.toString()}');
    }
  }
}

