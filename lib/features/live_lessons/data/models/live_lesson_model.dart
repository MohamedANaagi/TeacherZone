import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/live_lesson.dart';

/// Live Lesson Model - Data Layer
/// يمثل البيانات القادمة من Firestore
class LiveLessonModel extends LiveLesson {
  LiveLessonModel({
    required super.id,
    required super.title,
    required super.description,
    required super.meetingLink,
    required super.scheduledTime,
    required super.durationMinutes,
    required super.createdAt,
    required super.adminCode,
  });

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'meetingLink': meetingLink,
      'scheduledTime': scheduledTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'createdAt': createdAt.toIso8601String(),
      'adminCode': adminCode,
    };
  }

  /// Create from Firestore Document
  factory LiveLessonModel.fromFirestore(String id, Map<String, dynamic> data) {
    // معالجة scheduledTime
    DateTime scheduledTime;
    if (data['scheduledTime'] != null) {
      if (data['scheduledTime'] is Timestamp) {
        scheduledTime = (data['scheduledTime'] as Timestamp).toDate();
      } else if (data['scheduledTime'] is String) {
        try {
          scheduledTime = DateTime.parse(data['scheduledTime']);
        } catch (e) {
          scheduledTime = DateTime.now();
        }
      } else {
        scheduledTime = DateTime.now();
      }
    } else {
      scheduledTime = DateTime.now();
    }

    // معالجة createdAt
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

    return LiveLessonModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      meetingLink: data['meetingLink'] ?? '',
      scheduledTime: scheduledTime,
      durationMinutes: data['durationMinutes'] ?? 60, // Default 60 minutes if not specified
      createdAt: createdAt,
      adminCode: data['adminCode'] ?? '',
    );
  }

  /// Convert to Entity
  LiveLesson toEntity() {
    return LiveLesson(
      id: id,
      title: title,
      description: description,
      meetingLink: meetingLink,
      scheduledTime: scheduledTime,
      durationMinutes: durationMinutes,
      createdAt: createdAt,
      adminCode: adminCode,
    );
  }
}

