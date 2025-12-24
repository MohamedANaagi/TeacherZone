import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/test_result.dart';

/// نموذج نتيجة الاختبار - Data Layer
/// يمثل بيانات نتيجة الاختبار في Firestore
class TestResultModel extends TestResult {
  TestResultModel({
    required super.id,
    required super.testId,
    required super.studentCode,
    required super.totalQuestions,
    required super.correctAnswers,
    required super.wrongAnswers,
    required super.score,
    required super.completedAt,
    required super.answers,
  });

  /// تحويل إلى Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'testId': testId,
      'studentCode': studentCode,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'score': score,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers.map((key, value) => MapEntry(key, value)),
    };
  }

  /// إنشاء من Firestore Document
  factory TestResultModel.fromFirestore(String id, Map<String, dynamic> data) {
    // معالجة completedAt
    DateTime completedAt;
    if (data['completedAt'] != null) {
      if (data['completedAt'] is Timestamp) {
        completedAt = (data['completedAt'] as Timestamp).toDate();
      } else if (data['completedAt'] is String) {
        try {
          completedAt = DateTime.parse(data['completedAt']);
        } catch (e) {
          completedAt = DateTime.now();
        }
      } else {
        completedAt = DateTime.now();
      }
    } else {
      completedAt = DateTime.now();
    }

    // معالجة answers
    final answersData = data['answers'] as Map<dynamic, dynamic>? ?? {};
    final answers = answersData.map((key, value) => 
      MapEntry(key.toString(), value as int)
    );

    return TestResultModel(
      id: id,
      testId: data['testId'] ?? '',
      studentCode: data['studentCode'] ?? '',
      totalQuestions: data['totalQuestions'] ?? 0,
      correctAnswers: data['correctAnswers'] ?? 0,
      wrongAnswers: data['wrongAnswers'] ?? 0,
      score: (data['score'] ?? 0).toDouble(),
      completedAt: completedAt,
      answers: answers,
    );
  }

  /// تحويل من Entity
  factory TestResultModel.fromEntity(TestResult result) {
    return TestResultModel(
      id: result.id,
      testId: result.testId,
      studentCode: result.studentCode,
      totalQuestions: result.totalQuestions,
      correctAnswers: result.correctAnswers,
      wrongAnswers: result.wrongAnswers,
      score: result.score,
      completedAt: result.completedAt,
      answers: result.answers,
    );
  }
}

