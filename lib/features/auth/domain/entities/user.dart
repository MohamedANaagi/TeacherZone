/// User Entity - Pure Dart Class
/// لا يعتمد على أي مكتبة خارجية
class User {
  final String id;
  final String name;
  final String phone;
  final String? code;
  final DateTime? subscriptionEndDate;

  User({
    required this.id,
    required this.name,
    required this.phone,
    this.code,
    this.subscriptionEndDate,
  });

  /// حساب الأيام المتبقية في الاشتراك
  int get remainingDays {
    if (subscriptionEndDate == null) return 0;
    final now = DateTime.now();
    final difference = subscriptionEndDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  /// التحقق من أن الاشتراك لا يزال نشطاً
  bool get isSubscriptionActive {
    if (subscriptionEndDate == null) return false;
    return DateTime.now().isBefore(subscriptionEndDate!);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          code == other.code;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ phone.hashCode;
}
