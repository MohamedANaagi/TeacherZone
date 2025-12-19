import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../data/models/course_model.dart';
import '../../data/models/video_model.dart';
import '../widgets/admin_app_bar.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';

class AdminManageVideosScreen extends StatefulWidget {
  const AdminManageVideosScreen({super.key});

  @override
  State<AdminManageVideosScreen> createState() =>
      _AdminManageVideosScreenState();
}

class _AdminManageVideosScreenState extends State<AdminManageVideosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _videoTitleController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _videoDescriptionController = TextEditingController();

  String? _selectedCourseId;
  bool _isLoading = false;
  Future<List<CourseModel>>? _coursesFuture; // لحفظ Future الكورسات
  Future<List<VideoModel>>? _videosFuture; // لحفظ Future الفيديوهات

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void dispose() {
    _videoTitleController.dispose();
    _videoUrlController.dispose();
    _videoDescriptionController.dispose();
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

  void _loadVideosForCourse(String courseId) {
    setState(() {
      _videosFuture = InjectionContainer.adminRepo
          .getVideosByCourseId(courseId)
          .catchError((e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('فشل جلب الفيديوهات: ${e.toString()}'),
                  backgroundColor: AppColors.errorColor,
                ),
              );
            }
            return <VideoModel>[];
          });
    });
  }

  Future<void> _addVideo() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء اختيار الكورس أولاً'),
          backgroundColor: AppColors.warningColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await InjectionContainer.addVideoUseCase(
        courseId: _selectedCourseId!,
        title: _videoTitleController.text,
        url: _videoUrlController.text,
        description: _videoDescriptionController.text.isEmpty
            ? null
            : _videoDescriptionController.text,
      );

      _videoTitleController.clear();
      _videoUrlController.clear();
      _videoDescriptionController.clear();

      // إعادة تحميل الفيديوهات بعد الإضافة
      if (_selectedCourseId != null) {
        _loadVideosForCourse(_selectedCourseId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الفيديو بنجاح'),
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

  Future<void> _deleteVideo(String videoId) async {
    try {
      await InjectionContainer.adminRepo.deleteVideo(videoId);

      // إعادة تحميل الفيديوهات بعد الحذف
      if (_selectedCourseId != null) {
        _loadVideosForCourse(_selectedCourseId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفيديو بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الفيديو: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  String? _getSelectedCourseTitle(List<CourseModel> courses) {
    if (_selectedCourseId == null) return null;
    try {
      return courses.firstWhere((c) => c.id == _selectedCourseId).title;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AdminAppBar(title: 'إدارة الفيديوهات'),
      body: FutureBuilder<List<CourseModel>>(
        future: _coursesFuture,
        builder: (context, coursesSnapshot) {
          if (coursesSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (coursesSnapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'حدث خطأ في جلب الكورسات',
                    style: AppStyles.textSecondaryStyle,
                  ),
                ],
              ),
            );
          }

          final courses = coursesSnapshot.data ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // اختيار الكورس
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'اختر الكورس',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedCourseId,
                          decoration: InputDecoration(
                            hintText: 'اختر الكورس',
                            hintStyle: AppStyles.textSecondaryStyle,
                            prefixIcon: const Icon(
                              Icons.menu_book,
                              color: AppColors.primaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.secondaryColor,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                          ),
                          items: courses.map((course) {
                            return DropdownMenuItem<String>(
                              value: course.id,
                              child: Text(
                                course.title,
                                style: AppStyles.textPrimaryStyle,
                                textDirection: TextDirection.rtl,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCourseId = value;
                              if (value != null) {
                                _loadVideosForCourse(value);
                              } else {
                                _videosFuture = null;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (_selectedCourseId != null) ...[
                  const SizedBox(height: 24),
                  // نموذج إضافة فيديو جديد
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
                            'إضافة فيديو للكورس: ${_getSelectedCourseTitle(courses)}',
                            style: AppStyles.subHeadingStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          // حقل عنوان الفيديو
                          CustomTextField(
                            controller: _videoTitleController,
                            hintText: 'عنوان الفيديو',
                            icon: Icons.video_label,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال عنوان الفيديو';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // حقل رابط الفيديو
                          CustomTextField(
                            controller: _videoUrlController,
                            hintText: 'رابط الفيديو (URL)',
                            icon: Icons.link,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.ltr,
                            keyboardType: TextInputType.url,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال رابط الفيديو';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // حقل الوصف (اختياري)
                          CustomTextField(
                            controller: _videoDescriptionController,
                            hintText: 'وصف الفيديو (اختياري)',
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
                              onPressed: _isLoading ? null : _addVideo,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accentColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              AppColors.secondaryColor,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'إضافة الفيديو',
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
                  // قائمة الفيديوهات للكورس المختار
                  FutureBuilder<List<VideoModel>>(
                    future: _videosFuture,
                    builder: (context, videosSnapshot) {
                      if (videosSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (videosSnapshot.hasError) {
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
                                  'حدث خطأ في جلب الفيديوهات',
                                  style: AppStyles.textSecondaryStyle.copyWith(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final videos = videosSnapshot.data ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'فيديوهات الكورس (${videos.length})',
                            style: AppStyles.subHeadingStyle.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          videos.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.video_library_outlined,
                                          size: 60,
                                          color: AppColors.textLight,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'لا توجد فيديوهات لهذا الكورس',
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
                                  itemCount: videos.length,
                                  itemBuilder: (context, index) {
                                    final video = videos[index];
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
                                          // أيقونة الفيديو
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: AppColors.accentColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.play_circle_outline,
                                              color: AppColors.accentColor,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // معلومات الفيديو
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  video.title,
                                                  style: AppStyles
                                                      .subHeadingStyle
                                                      .copyWith(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (video.description != null &&
                                                    video
                                                        .description!
                                                        .isNotEmpty) ...[
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    video.description!,
                                                    style: AppStyles
                                                        .textSecondaryStyle,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                                const SizedBox(height: 4),
                                                Text(
                                                  video.url,
                                                  style: AppStyles
                                                      .textSecondaryStyle
                                                      .copyWith(fontSize: 11),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                _deleteVideo(video.id),
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
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
              ],
            ),
          );
        },
      ),
    );
  }
}
