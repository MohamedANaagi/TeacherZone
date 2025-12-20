import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final String? name;
  final String? phone;
  final String? imagePath;
  final DateTime? subscriptionEndDate;
  final bool isLoggedIn;

  const UserState({
    this.name,
    this.phone,
    this.imagePath,
    this.subscriptionEndDate,
    this.isLoggedIn = false,
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
    String? phone,
    String? imagePath,
    DateTime? subscriptionEndDate,
    bool? isLoggedIn,
    bool? clearName,
    bool? clearPhone,
    bool? clearImagePath,
    bool? clearSubscriptionEndDate,
  }) {
    return UserState(
      name: clearName == true ? null : (name ?? this.name),
      phone: clearPhone == true ? null : (phone ?? this.phone),
      imagePath: clearImagePath == true ? null : (imagePath ?? this.imagePath),
      subscriptionEndDate: clearSubscriptionEndDate == true
          ? null
          : (subscriptionEndDate ?? this.subscriptionEndDate),
      isLoggedIn: isLoggedIn != null ? isLoggedIn : this.isLoggedIn,
    );
  }

  @override
  List<Object?> get props => [
    name,
    phone,
    imagePath,
    subscriptionEndDate,
    isLoggedIn,
  ];
}
