import '../../../../core/errors/exceptions.dart';
import '../../data/models/code_model.dart';
import '../repositories/admin_repository.dart';

class UpdateCodeUseCase {
  final AdminRepository repository;

  UpdateCodeUseCase(this.repository);

  Future<void> call({
    required String codeId,
    String? code,
    String? name,
    String? phone,
    String? description,
    int? subscriptionDays,
    required String adminCode,
  }) async {
    // جلب الكود الحالي
    final codes = await repository.getCodes(adminCode: adminCode);
    final existingCode = codes.firstWhere(
      (c) => c.id == codeId,
      orElse: () => throw ValidationException('الكود غير موجود'),
    );

    // التحقق من أن الكود الجديد غير مستخدم (إذا تم تغييره)
    if (code != null && code.trim().isNotEmpty && code.trim() != existingCode.code) {
      // التحقق من أن الكود غير مستخدم في كود آخر
      final existingCodeWithSameCode = await repository.getCodeByCode(code.trim());
      if (existingCodeWithSameCode != null && existingCodeWithSameCode.id != codeId) {
        throw ValidationException('الكود مستخدم بالفعل');
      }
    }

    // حساب subscriptionEndDate الجديد إذا تم تغيير subscriptionDays
    DateTime? subscriptionEndDate = existingCode.subscriptionEndDate;
    if (subscriptionDays != null && subscriptionDays > 0) {
      subscriptionEndDate = DateTime.now().add(Duration(days: subscriptionDays));
    }

    // إنشاء CodeModel محدث
    final updatedCode = CodeModel(
      id: codeId,
      code: code?.trim() ?? existingCode.code,
      name: name?.trim() ?? existingCode.name,
      phone: phone?.trim() ?? existingCode.phone,
      description: description?.trim().isEmpty == true
          ? null
          : (description?.trim() ?? existingCode.description),
      profileImageUrl: existingCode.profileImageUrl,
      createdAt: existingCode.createdAt, // لا نغير createdAt
      subscriptionEndDate: subscriptionEndDate,
      deviceId: existingCode.deviceId, // لا نغير deviceId
      adminCode: adminCode,
    );

    await repository.updateCode(updatedCode);
  }
}

