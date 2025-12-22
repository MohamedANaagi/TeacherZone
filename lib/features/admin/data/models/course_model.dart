import 'package:cloud_firestore/cloud_firestore.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructor;
  final String duration;
  final int lessonsCount;
  final DateTime createdAt;
  final String adminCode; // كود الأدمن المرتبط بهذا الكورس

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.instructor,
    required this.duration,
    this.lessonsCount = 0,
    required this.createdAt,
    required this.adminCode,
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
      'adminCode': adminCode,
    };
  }

  // Create from Firestore Document
  factory CourseModel.fromFirestore(String id, Map<String, dynamic> data) {
    // معالجة createdAt - يدعم Timestamp و String
    DateTime createdAt;
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      } else if (data['createdAt'] is String) {
        try {
          createdAt = DateTime.parse(data['createdAt']);
        } catch (e) {
          createdAt = DateTime.now();
        }
      } else {
        createdAt = DateTime.now();
      }
    } else {
      createdAt = DateTime.now();
    }

    return CourseModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      instructor: data['instructor'] ?? '',
      duration: data['duration'] ?? '',
      lessonsCount: data['lessonsCount'] ?? 0,
      createdAt: createdAt,
      adminCode: data['adminCode'] ?? '',
    );
  }
}
