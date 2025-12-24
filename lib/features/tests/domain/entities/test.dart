/// كيان الاختبار - Domain Layer
class Test {
  final String id;
  final String title; // عنوان الاختبار
  final String description; // وصف الاختبار
  final String adminCode; // كود الأدمن الذي أنشأ الاختبار
  final DateTime createdAt; // تاريخ الإنشاء
  final int questionsCount; // عدد الأسئلة

  Test({
    required this.id,
    required this.title,
    required this.description,
    required this.adminCode,
    required this.createdAt,
    this.questionsCount = 0,
  });
}

