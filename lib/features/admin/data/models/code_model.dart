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
    };
  }

  // Create from Firestore Document
  factory CodeModel.fromFirestore(String id, Map<String, dynamic> data) {
    DateTime? subscriptionEndDate;
    if (data['subscriptionEndDate'] != null) {
      try {
        subscriptionEndDate = DateTime.parse(data['subscriptionEndDate']);
      } catch (e) {
        // Ignore parsing errors
        subscriptionEndDate = null;
      }
    }

    return CodeModel(
      id: id,
      code: data['code'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      description: data['description'],
      profileImageUrl: data['profileImageUrl'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
      subscriptionEndDate: subscriptionEndDate,
      deviceId: data['deviceId'],
    );
  }
}
