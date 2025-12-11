import '../models/user_model.dart';

/// Remote Data Source Interface
/// يعرف العمليات للتعامل مع API
abstract class AuthRemoteDataSource {
  /// تسجيل الدخول باستخدام الكود
  Future<UserModel> login({
    required String code,
    required String name,
    required String email,
  });

  /// تسجيل الخروج
  Future<void> logout();

  /// الحصول على المستخدم الحالي
  Future<UserModel?> getCurrentUser();

  /// التحقق من حالة تسجيل الدخول
  Future<bool> isLoggedIn();
}

/// Remote Data Source Implementation
/// TODO: استبدل هذا بتطبيق حقيقي يستخدم http أو dio
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  // TODO: أضف http.Client أو Dio هنا
  // final http.Client client;

  // AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> login({
    required String code,
    required String name,
    required String email,
  }) async {
    // TODO: استبدل هذا بطلب API حقيقي
    // final response = await client.post(
    //   Uri.parse('https://api.example.com/auth/login'),
    //   body: {'code': code, 'name': name, 'email': email},
    // );
    //
    // if (response.statusCode == 200) {
    //   return UserModel.fromJson(jsonDecode(response.body));
    // } else {
    //   throw ServerException('فشل تسجيل الدخول');
    // }

    // Simulation - حذف هذا عند إضافة API حقيقي
    await Future.delayed(const Duration(seconds: 1));

    // حساب تاريخ انتهاء الاشتراك (30 يوم من الآن)
    final subscriptionEndDate = DateTime.now().add(const Duration(days: 30));

    return UserModel(
      id: '1',
      name: name,
      email: email,
      code: code,
      subscriptionEndDate: subscriptionEndDate,
    );
  }

  @override
  Future<void> logout() async {
    // TODO: تنفيذ تسجيل الخروج
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    // TODO: جلب المستخدم من Local Storage
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    // TODO: التحقق من حالة تسجيل الدخول
    return false;
  }
}
