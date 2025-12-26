/// Live Lesson Entity - Domain Layer
/// كيان الدرس المباشر (Pure Dart Class)
class LiveLesson {
  final String id;
  final String title;
  final String description;
  final String meetingLink; // رابط الزوم أو جوجل ميت
  final DateTime scheduledTime; // الوقت المحدد لبدء الدرس
  final int durationMinutes; // مدة الدرس بالدقائق
  final DateTime createdAt; // وقت إنشاء الدرس
  final String adminCode; // كود الأدمن الذي أنشأ الدرس

  LiveLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.meetingLink,
    required this.scheduledTime,
    required this.durationMinutes,
    required this.createdAt,
    required this.adminCode,
  });

  /// حساب وقت انتهاء الدرس
  DateTime get endTime => scheduledTime.add(Duration(minutes: durationMinutes));
  
  /// التحقق من انتهاء الدرس
  bool isEnded(DateTime now) => now.isAfter(endTime);
  
  /// التحقق من بدء الدرس
  bool isStarted(DateTime now) => now.isAfter(scheduledTime);
  
  /// التحقق من أن الدرس جاري حالياً
  bool isLive(DateTime now) => isStarted(now) && !isEnded(now);
}

