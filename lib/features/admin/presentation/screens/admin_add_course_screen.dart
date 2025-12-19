import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../data/models/course_model.dart';
import '../widgets/admin_app_bar.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';

class AdminAddCourseScreen extends StatefulWidget {
  const AdminAddCourseScreen({super.key});

  @override
  State<AdminAddCourseScreen> createState() => _AdminAddCourseScreenState();
}

class _AdminAddCourseScreenState extends State<AdminAddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructorController = TextEditingController();
  final _durationController = TextEditingController();
  bool _isLoading = false;
  Future<List<CourseModel>>? _coursesFuture; // لحفظ Future الكورسات

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _instructorController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _loadCourses() {
    setState(() {
      _coursesFuture = InjectionContainer.adminRepo.getCourses().catchError((
        e,
      ) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('فشل جلب الكورسات: ${e.toString()}'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
        return <CourseModel>[];
      });
    });
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await InjectionContainer.addCourseUseCase(
        title: _titleController.text,
        description: _descriptionController.text,
        instructor: _instructorController.text,
        duration: _durationController.text,
      );

      _titleController.clear();
      _descriptionController.clear();
      _instructorController.clear();
      _durationController.clear();

      // إعادة تحميل قائمة الكورسات
      _loadCourses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الكورس بنجاح'),
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

  Future<void> _deleteCourse(String courseId) async {
    try {
      await InjectionContainer.adminRepo.deleteCourse(courseId);

      // إعادة تحميل قائمة الكورسات
      _loadCourses();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الكورس بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الكورس: ${e.toString()}'),
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
      appBar: AdminAppBar(title: 'إضافة الكورسات'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // نموذج إضافة كورس جديد
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
                      'إضافة كورس جديد',
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // حقل العنوان
                    CustomTextField(
                      controller: _titleController,
                      hintText: 'عنوان الكورس',
                      icon: Icons.title,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عنوان الكورس';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // حقل الوصف
                    CustomTextField(
                      controller: _descriptionController,
                      hintText: 'وصف الكورس',
                      icon: Icons.description,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال وصف الكورس';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // حقل المدرب
                    CustomTextField(
                      controller: _instructorController,
                      hintText: 'اسم المدرب',
                      icon: Icons.person,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال اسم المدرب';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // حقل المدة
                    CustomTextField(
                      controller: _durationController,
                      hintText: 'مدة الكورس (مثال: 20 ساعة)',
                      icon: Icons.access_time,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال مدة الكورس';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    // زر الإضافة
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _addCourse,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.courseColor,
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
                                'إضافة الكورس',
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
            // قائمة الكورسات المضافة
            FutureBuilder<List<CourseModel>>(
              future: _coursesFuture ?? Future.value(<CourseModel>[]),
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
                            'حدث خطأ في جلب الكورسات',
                            style: AppStyles.textSecondaryStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final courses = snapshot.data ?? [];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الكورسات المضافة (${courses.length})',
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    courses.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.menu_book_outlined,
                                    size: 60,
                                    color: AppColors.textLight,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد كورسات مضافة',
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
                            itemCount: courses.length,
                            itemBuilder: (context, index) {
                              final course = courses[index];
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
                                                course.title,
                                                style: AppStyles.subHeadingStyle
                                                    .copyWith(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                course.description,
                                                style: AppStyles
                                                    .textSecondaryStyle,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.person_outline,
                                                    size: 16,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    course.instructor,
                                                    style: AppStyles
                                                        .textSecondaryStyle
                                                        .copyWith(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Icon(
                                                    Icons.access_time,
                                                    size: 16,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    course.duration,
                                                    style: AppStyles
                                                        .textSecondaryStyle
                                                        .copyWith(fontSize: 12),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Icon(
                                                    Icons.play_circle_outline,
                                                    size: 16,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${course.lessonsCount} فيديو',
                                                    style: AppStyles
                                                        .textSecondaryStyle
                                                        .copyWith(fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () =>
                                              _deleteCourse(course.id),
                                          icon: const Icon(
                                            Icons.delete_outline,
                                          ),
                                          color: AppColors.errorColor,
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
