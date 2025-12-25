import 'package:cloud_firestore/cloud_firestore.dart';

/// AdminCodeModel
/// نموذج بيانات كود الأدمن
class AdminCodeModel {
  final String id;
  final String adminCode; // كود الأدمن (مثل: "ADMIN001")
  final String name; // اسم الأدمن
  final String? phone; // رقم هاتف الأدمن (اختياري)
  final String? description; // وصف اختياري
  final String? imageUrl; // رابط صورة الأدمن من Bunny Storage (اختياري)
  final DateTime createdAt; // تاريخ الإنشاء

  AdminCodeModel({
    required this.id,
    required this.adminCode,
    required this.name,
    this.phone,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'adminCode': adminCode,
      'name': name,
      if (phone != null && phone!.isNotEmpty) 'phone': phone,
      'description': description ?? '',
      if (imageUrl != null && imageUrl!.isNotEmpty) 'imageUrl': imageUrl,
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
      phone: data['phone']?.toString(),
      description: data['description'],
      imageUrl: data['imageUrl']?.toString(),
      createdAt: createdAt,
    );
  }
}

