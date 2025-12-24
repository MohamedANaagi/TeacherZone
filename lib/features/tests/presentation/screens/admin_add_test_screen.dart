import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../data/models/test_model.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../admin/presentation/widgets/admin_app_bar.dart';
import 'admin_manage_questions_screen.dart';

class AdminAddTestScreen extends StatefulWidget {
  const AdminAddTestScreen({super.key});

  @override
  State<AdminAddTestScreen> createState() => _AdminAddTestScreenState();
}

class _AdminAddTestScreenState extends State<AdminAddTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  Future<List<TestModel>>? _testsFuture;

  @override
  void initState() {
    super.initState();
    _loadTests();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<List<TestModel>> _getAdminCodeAndLoadTests() async {
    final adminCode = context.read<UserCubit>().state.adminCode;
    final tests = await InjectionContainer.testRepo.getTests(adminCode: adminCode);
    // Convert Test entities to TestModel
    return tests.map((test) => TestModel(
      id: test.id,
      title: test.title,
      description: test.description,
      adminCode: test.adminCode,
      createdAt: test.createdAt,
      questionsCount: test.questionsCount,
    )).toList();
  }

  void _loadTests() {
    setState(() {
      _testsFuture = _getAdminCodeAndLoadTests().catchError((e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل جلب الاختبارات: ${e.toString()}'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
        return <TestModel>[];
      });
    });
  }

  Future<void> _addTest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final adminCode = context.read<UserCubit>().state.adminCode;
      if (adminCode == null || adminCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('كود الأدمن غير موجود. يجب تسجيل الدخول بكود أدمن أولاً'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      await InjectionContainer.addTestUseCase(
        title: _titleController.text,
        description: _descriptionController.text,
        adminCode: adminCode,
      );

      _titleController.clear();
      _descriptionController.clear();

      _loadTests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الاختبار بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteTest(String testId) async {
    try {
      await InjectionContainer.testRepo.deleteTest(testId);
      _loadTests();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الاختبار بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الاختبار: ${e.toString()}'),
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
      appBar: AdminAppBar(title: 'إدارة الاختبارات'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نموذج إضافة اختبار جديد
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
                      'إضافة اختبار جديد',
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _titleController,
                      hintText: 'عنوان الاختبار',
                      icon: Icons.quiz,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عنوان الاختبار';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'وصف الاختبار',
                      icon: Icons.description,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال وصف الاختبار';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addTest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.examColor,
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
                                'إضافة الاختبار',
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
            // قائمة الاختبارات المضافة
            FutureBuilder<List<TestModel>>(
              future: _testsFuture ?? Future.value(<TestModel>[]),
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
                            'حدث خطأ في جلب الاختبارات',
                            style: AppStyles.textSecondaryStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final tests = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الاختبارات المضافة (${tests.length})',
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    tests.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 60,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد اختبارات مضافة',
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
                            itemCount: tests.length,
                            itemBuilder: (context, index) {
                              final test = tests[index];
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                test.title,
                                                style: AppStyles.subHeadingStyle
                                                    .copyWith(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                test.description,
                                                style: AppStyles
                                                    .textSecondaryStyle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.help_outline,
                                                    size: 16,
                                                    color: AppColors
                                                        .textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${test.questionsCount} سؤال',
                                                    style: AppStyles
                                                        .textSecondaryStyle
                                                        .copyWith(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AdminManageQuestionsScreen(
                                                      test: test,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                Icons.edit_outlined,
                                              ),
                                              color: AppColors.primaryColor,
                                              tooltip: 'إدارة الأسئلة',
                                            ),
                                            IconButton(
                                              onPressed: () =>
                                                  _deleteTest(test.id),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                              ),
                                              color: AppColors.errorColor,
                                            ),
                                          ],
                                        ),
                                      ],
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
    );
  }
}
