/// كيان السؤال - Domain Layer
/// يحتوي على بيانات السؤال والإجابات
class Question {
  final String id;
  final String testId; // معرف الاختبار المرتبط به
  final String questionText; // نص السؤال
  final String? imageUrl; // رابط الصورة (اختياري)
  final List<String> options; // قائمة الخيارات (اختيار متعدد)
  final int correctAnswerIndex; // فهرس الإجابة الصحيحة (0-based)
  final int order; // ترتيب السؤال في الاختبار

  Question({
    required this.id,
    required this.testId,
    required this.questionText,
    this.imageUrl,
    required this.options,
    required this.correctAnswerIndex,
    this.order = 0,
  });

  /// التحقق من صحة الإجابة
  bool isCorrect(int selectedIndex) {
    return selectedIndex == correctAnswerIndex;
  }
}

