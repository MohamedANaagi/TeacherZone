/// كيان نتيجة الاختبار - Domain Layer
class TestResult {
  final String id;
  final String testId; // معرف الاختبار
  final String studentCode; // كود الطالب
  final int totalQuestions; // إجمالي عدد الأسئلة
  final int correctAnswers; // عدد الإجابات الصحيحة
  final int wrongAnswers; // عدد الإجابات الخاطئة
  final double score; // النسبة المئوية
  final DateTime completedAt; // تاريخ إتمام الاختبار
  final Map<String, int> answers; // Map<questionId, selectedAnswerIndex>

  TestResult({
    required this.id,
    required this.testId,
    required this.studentCode,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.score,
    required this.completedAt,
    required this.answers,
  });

  /// حساب النسبة المئوية
  double get percentage => score;
}

