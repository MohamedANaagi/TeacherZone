class CodeModel {
  final String id;
  final String code;
  final String name; // اسم المستخدم المرتبط بالكود
  final String phone; // رقم هاتف المستخدم المرتبط بالكود
  final String? description;
  final String? profileImageUrl; // رابط صورة البروفايل في Firebase Storage
  final DateTime createdAt;

  CodeModel({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    this.description,
    this.profileImageUrl,
    required this.createdAt,
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
    };
  }

  // Create from Firestore Document
  factory CodeModel.fromFirestore(String id, Map<String, dynamic> data) {
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
    );
  }
}
