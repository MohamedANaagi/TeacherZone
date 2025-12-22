import '../../../../core/errors/exceptions.dart';
import '../../data/models/code_model.dart';
import '../repositories/admin_repository.dart';

class AddCodeUseCase {
  final AdminRepository repository;

  AddCodeUseCase(this.repository);

  Future<void> call({
    required String code,
    required String name,
    required String phone,
    String? description,
    int? subscriptionDays, // عدد أيام الاشتراك
    required String adminCode, // كود الأدمن المرتبط بهذا الكود
  }) async {
    // Validation
    if (code.trim().isEmpty) {
      throw ValidationException('الكود مطلوب');
    }
    if (name.trim().isEmpty) {
      throw ValidationException('الاسم مطلوب');
    }
    if (phone.trim().isEmpty) {
      throw ValidationException('رقم الهاتف مطلوب');
    }
    if (adminCode.trim().isEmpty) {
      throw ValidationException('كود الأدمن مطلوب');
    }

    // التحقق من صحة رقم الهاتف
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (!phoneRegex.hasMatch(cleanPhone)) {
      throw ValidationException(
        'رقم الهاتف غير صحيح. يجب أن يحتوي على 10-15 رقم',
      );
    }

    // التحقق من عدم وجود كود مكرر
    final existingCode = await repository.getCodeByCode(code.trim());
    if (existingCode != null) {
      throw ValidationException(
        'الكود "${code.trim()}" مستخدم بالفعل. لا يمكن إضافة كود مكرر',
      );
    }

    // حساب تاريخ انتهاء الاشتراك
    DateTime? subscriptionEndDate;
    if (subscriptionDays != null && subscriptionDays > 0) {
      subscriptionEndDate = DateTime.now().add(Duration(days: subscriptionDays));
    }

    final codeModel = CodeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: code.trim(),
      name: name.trim(),
      phone: cleanPhone,
      description: description?.trim(),
      createdAt: DateTime.now(),
      subscriptionEndDate: subscriptionEndDate,
      adminCode: adminCode.trim(),
    );

    await repository.addCode(codeModel);
  }
}
