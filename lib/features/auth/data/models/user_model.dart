import '../../domain/entities/user.dart';

/// User Model - Data Layer
/// يمثل البيانات القادمة من API أو Database
class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.code,
    super.subscriptionEndDate,
  });

  /// تحويل JSON/Map إلى UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    DateTime? subscriptionEndDate;

    // معالجة Timestamp من JSON
    if (json['subscriptionEndDate'] != null) {
      if (json['subscriptionEndDate'] is DateTime) {
        subscriptionEndDate = json['subscriptionEndDate'] as DateTime;
      } else if (json['subscriptionEndDate'] is Map) {
        // Timestamp object (seconds/milliseconds)
        final timestamp = json['subscriptionEndDate'];
        if (timestamp['seconds'] != null) {
          subscriptionEndDate = DateTime.fromMillisecondsSinceEpoch(
            (timestamp['seconds'] as int) * 1000,
          );
        }
      } else if (json['subscriptionEndDate'] is String) {
        // ISO 8601 string
        try {
          subscriptionEndDate = DateTime.parse(json['subscriptionEndDate']);
        } catch (e) {
          // Ignore parsing errors
        }
      }
    }

    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      code: json['code']?.toString(),
      subscriptionEndDate: subscriptionEndDate,
    );
  }

  /// تحويل UserModel إلى JSON/Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (code != null) 'code': code,
      if (subscriptionEndDate != null)
        'subscriptionEndDate': subscriptionEndDate!.toIso8601String(),
    };
  }

  /// تحويل UserModel إلى User Entity
  User toEntity() {
    return User(
      id: id,
      name: name,
      email: email,
      code: code,
      subscriptionEndDate: subscriptionEndDate,
    );
  }
}
