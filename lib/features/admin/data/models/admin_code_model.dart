import 'package:cloud_firestore/cloud_firestore.dart';

/// AdminCodeModel
/// نموذج بيانات كود الأدمن
class AdminCodeModel {
  final String id;
  final String adminCode; // كود الأدمن (مثل: "ADMIN001")
  final String name; // اسم الأدمن
  final String? description; // وصف اختياري
  final DateTime createdAt; // تاريخ الإنشاء

  AdminCodeModel({
    required this.id,
    required this.adminCode,
    required this.name,
    this.description,
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'adminCode': adminCode,
      'name': name,
      'description': description ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore Document
  factory AdminCodeModel.fromFirestore(String id, Map<String, dynamic> data) {
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

    return AdminCodeModel(
      id: id,
      adminCode: data['adminCode'] ?? '',
      name: data['name'] ?? '',
      description: data['description'],
      createdAt: createdAt,
    );
  }
}

