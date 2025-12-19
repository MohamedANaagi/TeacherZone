import '../../../../core/errors/exceptions.dart';
import '../../data/models/code_model.dart';
import '../repositories/admin_repository.dart';

class AddCodeUseCase {
  final AdminRepository repository;

  AddCodeUseCase(this.repository);

  Future<void> call({required String code, String? description}) async {
    // Validation
    if (code.trim().isEmpty) {
      throw ValidationException('الكود مطلوب');
    }

    final codeModel = CodeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      code: code.trim(),
      description: description?.trim(),
      createdAt: DateTime.now(),
    );

    await repository.addCode(codeModel);
  }
}
