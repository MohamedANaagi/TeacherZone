import 'package:cloud_firestore/cloud_firestore.dart';

class CodeModel {
  final String id;
  final String code;
  final String name; // اسم المستخدم المرتبط بالكود
  final String phone; // رقم هاتف المستخدم المرتبط بالكود
  final String? description;
  final String? profileImageUrl; // رابط صورة البروفايل في Firebase Storage
  final DateTime createdAt;
  final DateTime? subscriptionEndDate; // تاريخ انتهاء الاشتراك
  final String? deviceId; // معرف الجهاز المرتبط بالكود (للمنع من استخدام الكود على أكثر من جهاز)
  final String adminCode; // كود الأدمن المرتبط بهذا الكود

  CodeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    this.description,
    this.profileImageUrl,
    required this.createdAt,
    this.subscriptionEndDate,
    this.deviceId,
    required this.adminCode,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'name': name,
      'phone': phone,
      'description': description ?? '',
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      if (subscriptionEndDate != null)
        'subscriptionEndDate': subscriptionEndDate!.toIso8601String(),
      if (deviceId != null) 'deviceId': deviceId,
      'adminCode': adminCode,
    };
  }

  // Create from Firestore Document
  factory CodeModel.fromFirestore(String id, Map<String, dynamic> data) {
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

    // معالجة subscriptionEndDate - يدعم Timestamp و String
    DateTime? subscriptionEndDate;
    if (data['subscriptionEndDate'] != null) {
      if (data['subscriptionEndDate'] is Timestamp) {
        subscriptionEndDate = (data['subscriptionEndDate'] as Timestamp).toDate();
      } else if (data['subscriptionEndDate'] is String) {
        try {
          subscriptionEndDate = DateTime.parse(data['subscriptionEndDate']);
        } catch (e) {
          subscriptionEndDate = null;
        }
      }
    }

    return CodeModel(
      id: id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      description: data['description'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: createdAt,
      subscriptionEndDate: subscriptionEndDate,
      deviceId: data['deviceId'],
      adminCode: data['adminCode'] ?? '',
    );
  }
}
