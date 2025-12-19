class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final int lessonsCount;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    this.lessonsCount = 0,
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'instructor': instructor,
      'duration': duration,
      'lessonsCount': lessonsCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore Document
  factory CourseModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CourseModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
      duration: data['duration'] ?? '',
      lessonsCount: data['lessonsCount'] ?? 0,
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }
}
