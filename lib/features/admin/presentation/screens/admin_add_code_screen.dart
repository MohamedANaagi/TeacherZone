import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../data/models/code_model.dart';
import '../widgets/admin_app_bar.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';

class AdminAddCodeScreen extends StatefulWidget {
  const AdminAddCodeScreen({super.key});

  @override
  State<AdminAddCodeScreen> createState() => _AdminAddCodeScreenState();
}

class _AdminAddCodeScreenState extends State<AdminAddCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  Future<List<CodeModel>>? _codesFuture; // لحفظ Future الأكواد
  int _refreshKey = 0; // لإعادة بناء FutureBuilder

  @override
  void initState() {
    super.initState();
    _loadCodes();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadCodes() {
    // إنشاء Future جديد في كل مرة لإجبار FutureBuilder على إعادة البناء
    final newFuture = InjectionContainer.adminRepo.getCodes().catchError((e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جلب الأكواد: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return <CodeModel>[];
    });

    setState(() {
      _refreshKey++; // تحديث key لإعادة بناء FutureBuilder
      _codesFuture = newFuture;
    });
  }

  Future<void> _addCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await InjectionContainer.addCodeUseCase(
        code: _codeController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
      );

      if (mounted) {
        _codeController.clear();
        _descriptionController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الكود بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );

        // انتظار قصير ثم إعادة تحميل للتأكد من تحديث Firestore
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _loadCodes();
          }
        });
      }
    } on ValidationException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteCode(String codeId) async {
    try {
      await InjectionContainer.adminRepo.deleteCode(codeId);

      // إعادة تحميل قائمة الأكواد
      _loadCodes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الكود بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الكود: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AdminAppBar(title: 'إضافة الأكواد'),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadCodes();
          // انتظار قليل للتأكد من اكتمال التحميل
          await Future.delayed(const Duration(milliseconds: 300));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // نموذج إضافة كود جديد
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إضافة كود جديد',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // حقل الكود
                      CustomTextField(
                        controller: _codeController,
                        hintText: 'أدخل الكود',
                        icon: Icons.vpn_key,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال الكود';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // حقل الوصف (اختياري)
                      CustomTextField(
                        controller: _descriptionController,
                        hintText: 'الوصف (اختياري)',
                        icon: Icons.description,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                      // زر الإضافة
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.secondaryColor,
                                    ),
                                  ),
                                )
                              : Text(
                                  'إضافة الكود',
                                  style: AppStyles.subTextStyle.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // قائمة الأكواد المضافة
              FutureBuilder<List<CodeModel>>(
                key: ValueKey(_refreshKey),
                future: _codesFuture ?? Future.value(<CodeModel>[]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 60,
                              color: AppColors.errorColor,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'حدث خطأ في جلب الأكواد',
                              style: AppStyles.textSecondaryStyle.copyWith(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final codes = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الأكواد المضافة (${codes.length})',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      codes.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(40),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.inbox_outlined,
                                      size: 60,
                                      color: AppColors.textLight,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'لا توجد أكواد مضافة',
                                      style: AppStyles.textSecondaryStyle
                                          .copyWith(fontSize: 16),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: codes.length,
                              itemBuilder: (context, index) {
                                final code = codes[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppColors.borderColor,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              code.code,
                                              style: AppStyles.subHeadingStyle
                                                  .copyWith(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                            if (code.description != null &&
                                                code
                                                    .description!
                                                    .isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Text(
                                                code.description!,
                                                style: AppStyles
                                                    .textSecondaryStyle,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteCode(code.id),
                                        icon: const Icon(Icons.delete_outline),
                                        color: AppColors.errorColor,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
