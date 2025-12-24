import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/test.dart';

/// نموذج الاختبار - Data Layer
/// يمثل بيانات الاختبار في Firestore
class TestModel extends Test {
  TestModel({
    required super.id,
    required super.title,
    required super.description,
    required super.adminCode,
    required super.createdAt,
    super.questionsCount,
  });

  /// تحويل إلى Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'adminCode': adminCode,
      'createdAt': createdAt.toIso8601String(),
      'questionsCount': questionsCount,
    };
  }

  /// إنشاء من Firestore Document
  factory TestModel.fromFirestore(String id, Map<String, dynamic> data) {
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

    return TestModel(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      adminCode: data['adminCode'] ?? '',
      createdAt: createdAt,
      questionsCount: data['questionsCount'] ?? 0,
    );
  }

  /// تحويل من Entity
  factory TestModel.fromEntity(Test test) {
    return TestModel(
      id: test.id,
      title: test.title,
      description: test.description,
      adminCode: test.adminCode,
      createdAt: test.createdAt,
      questionsCount: test.questionsCount,
    );
  }
}

