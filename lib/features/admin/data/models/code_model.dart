class CodeModel {
  final String id;
  final String code;
  final String? description;
  final DateTime createdAt;

  CodeModel({
    required this.id,
    required this.code,
    this.description,
    required this.createdAt,
  });

  // Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'code': code,
      'description': description ?? '',
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from Firestore Document
  factory CodeModel.fromFirestore(String id, Map<String, dynamic> data) {
    return CodeModel(
      id: id,
      code: data['code'] ?? '',
      description: data['description'],
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }
}
