import 'package:equatable/equatable.dart';

class UserState extends Equatable {
  final String? name;
  final String? phone;
  final String? imagePath; // رابط الصورة من Bunny Storage (URL)
  final String? code; // كود المستخدم
  final String? adminCode; // كود الأدمن المرتبط بهذا المستخدم
  final String? adminName; // اسم الأدمن
  final String? adminPhone; // رقم هاتف الأدمن
  final String? adminDescription; // وصف الأدمن
  final String? adminImageUrl; // رابط صورة الأدمن من Bunny Storage
  final DateTime? subscriptionEndDate;
  final bool isLoggedIn;

  const UserState({
    this.name,
    this.phone,
    this.imagePath,
    this.code,
    this.adminCode,
    this.adminName,
    this.adminPhone,
    this.adminDescription,
    this.adminImageUrl,
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
    String? code,
    String? adminCode,
    String? adminName,
    String? adminPhone,
    String? adminDescription,
    String? adminImageUrl,
    DateTime? subscriptionEndDate,
    bool? isLoggedIn,
    bool? clearName,
    bool? clearPhone,
    bool? clearImagePath,
    bool? clearCode,
    bool? clearAdminCode,
    bool? clearAdminName,
    bool? clearAdminPhone,
    bool? clearAdminDescription,
    bool? clearAdminImageUrl,
    bool? clearSubscriptionEndDate,
  }) {
    return UserState(
      name: clearName == true ? null : (name ?? this.name),
      phone: clearPhone == true ? null : (phone ?? this.phone),
      imagePath: clearImagePath == true ? null : (imagePath ?? this.imagePath),
      code: clearCode == true ? null : (code ?? this.code),
      adminCode: clearAdminCode == true ? null : (adminCode ?? this.adminCode),
      adminName: clearAdminName == true ? null : (adminName ?? this.adminName),
      adminPhone: clearAdminPhone == true ? null : (adminPhone ?? this.adminPhone),
      adminDescription: clearAdminDescription == true
          ? null
          : (adminDescription ?? this.adminDescription),
      adminImageUrl: clearAdminImageUrl == true
          ? null
          : (adminImageUrl ?? this.adminImageUrl),
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
    code,
    adminCode,
    adminName,
    adminPhone,
    adminDescription,
    adminImageUrl,
    subscriptionEndDate,
    isLoggedIn,
  ];
}
