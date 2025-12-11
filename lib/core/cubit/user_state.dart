import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final String? name;
  final String? email;
  final String? imagePath;
  final DateTime? subscriptionEndDate;

  const UserState({
    this.name,
    this.email,
    this.imagePath,
    this.subscriptionEndDate,
  });

  /// حساب الأيام المتبقية على الاشتراك
  int get remainingDays {
    if (subscriptionEndDate == null) return 0;
    final now = DateTime.now();
    final difference = subscriptionEndDate!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }

  /// نسخ الحالة مع تحديث القيم
  UserState copyWith({
    String? name,
    String? email,
    String? imagePath,
    DateTime? subscriptionEndDate,
    bool? clearName,
    bool? clearEmail,
    bool? clearImagePath,
    bool? clearSubscriptionEndDate,
  }) {
    return UserState(
      name: clearName == true ? null : (name ?? this.name),
      email: clearEmail == true ? null : (email ?? this.email),
      imagePath: clearImagePath == true ? null : (imagePath ?? this.imagePath),
      subscriptionEndDate: clearSubscriptionEndDate == true
          ? null
          : (subscriptionEndDate ?? this.subscriptionEndDate),
    );
  }

  @override
  List<Object?> get props => [name, email, imagePath, subscriptionEndDate];
}

