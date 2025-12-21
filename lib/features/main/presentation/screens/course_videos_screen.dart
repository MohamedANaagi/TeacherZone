import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../videos/presentation/cubit/videos_cubit.dart';
import '../../../videos/presentation/cubit/videos_state.dart';
import '../../../courses/presentation/cubit/courses_cubit.dart';
import '../../../courses/presentation/cubit/courses_state.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../widgets/video_item_widget.dart';

class CourseVideosScreen extends StatefulWidget {
  final Map<String, dynamic> course;

  const CourseVideosScreen({super.key, required this.course});

  @override
  State<CourseVideosScreen> createState() => _CourseVideosScreenState();
}

class _CourseVideosScreenState extends State<CourseVideosScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل فيديوهات الكورس عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final courseId = widget.course['id'] as String;
        final userCode = context.read<UserCubit>().state.code;
        context.read<VideosCubit>().loadCourseVideos(
          courseId,
          userCode: userCode,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseId = widget.course['id'] as String;
    final color = Color(widget.course['color'] as int);

    return BlocBuilder<CoursesCubit, CoursesState>(
      builder: (context, coursesState) {
        // الحصول على الكورس المحدث من CoursesCubit
        final updatedCourse = coursesState.courses.isNotEmpty
            ? coursesState.courses.firstWhere(
                (course) => course['id'] == courseId,
                orElse: () => widget.course,
              )
            : widget.course;
        
        return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CustomScrollView(
        slivers: [
          // App Bar مع صورة الكورس
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: color,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.secondaryColor,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                ),
                child: Stack(
                  children: [
                    // أيقونة الكورس
                    Center(
                      child: Icon(
                        _getCourseIcon(widget.course['image'] as String),
                        size: 100,
                        color: AppColors.secondaryColor.withOpacity(0.3),
                      ),
                    ),
                    // معلومات الكورس
                    Positioned(
                      bottom: 20,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.course['title'] as String,
                            style: AppStyles.mainTextStyle.copyWith(
                              color: AppColors.secondaryColor,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                size: 16,
                                color: AppColors.secondaryColor.withOpacity(
                                  0.9,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.course['instructor'] as String,
                                style: AppStyles.subTextStyle.copyWith(
                                  fontSize: 14,
                                  color: AppColors.secondaryColor.withOpacity(
                                    0.9,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // قائمة الفيديوهات
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // معلومات الكورس
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        _buildInfoItem(
                          icon: Icons.play_circle_outline,
                          label: 'الدروس',
                          value: '${widget.course['lessonsCount']}',
                          color: color,
                        ),
                        const SizedBox(width: 24),
                        _buildInfoItem(
                          icon: Icons.access_time,
                          label: 'المدة',
                          value: widget.course['duration'] as String,
                          color: color,
                        ),
                        const SizedBox(width: 24),
                        _buildInfoItem(
                          icon: Icons.trending_up,
                          label: 'التقدم',
                          value: '${updatedCourse['progress']}%',
                          color: color,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // عنوان قائمة الفيديوهات
                  Text(
                    'قائمة الدروس',
                    style: AppStyles.headingStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 16),
                  // قائمة الفيديوهات
                  BlocBuilder<VideosCubit, VideosState>(
                    builder: (context, state) {
                      final videos = state.getVideosForCourse(courseId);
                      final isLoading = state.isLoadingCourse(courseId);
                      final error = state.getErrorForCourse(courseId);

                      if (isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (error != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppColors.textLight,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  error,
                                  style: AppStyles.textSecondaryStyle,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    final userCode = context.read<UserCubit>().state.code;
                                    context
                                        .read<VideosCubit>()
                                        .loadCourseVideos(courseId, userCode: userCode);
                                  },
                                  child: const Text('إعادة المحاولة'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (videos.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.video_library_outlined,
                                  size: 48,
                                  color: AppColors.textLight,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'لا توجد فيديوهات متاحة',
                                  style: AppStyles.textSecondaryStyle,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: videos
                            .map(
                              (video) => RepaintBoundary(
                                child: VideoItemWidget(
                                  video: video,
                                  courseColor: color,
                                  courseId: courseId,
                                  onTap: () async {
                                    await context.push(
                                      '${AppRouters.videoPlayerScreen}/${video['id']}',
                                      extra: {
                                        'url': video['url'] as String,
                                        'title': video['title'] as String,
                                        'description': video['description'] as String?,
                                        'courseId': courseId,
                                      },
                                    );
                                    // عند الرجوع من شاشة الفيديو، حدّث حالة المشاهدة
                                    if (mounted) {
                                      final videosCubit = context.read<VideosCubit>();
                                      final userCode = context.read<UserCubit>().state.code;
                                      videosCubit.markVideoAsWatched(
                                        courseId,
                                        video['id'] as String,
                                        userCode: userCode,
                                      );
                                      // تحديث التقدم
                                      _updateCourseProgress(context, courseId);
                                    }
                                  },
                                  onWatchedChanged: (courseId, videoId) {
                                    final videosCubit = context.read<VideosCubit>();
                                    final userCode = context.read<UserCubit>().state.code;
                                    videosCubit.markVideoAsWatched(
                                      courseId,
                                      videoId,
                                      userCode: userCode,
                                    );
                                    // تحديث التقدم
                                    _updateCourseProgress(context, courseId);
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.subHeadingStyle.copyWith(
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppStyles.textSecondaryStyle.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// تحديث تقدم الكورس بناءً على الفيديوهات المشاهدة المحفوظة
  void _updateCourseProgress(BuildContext context, String courseId) {
    final userCode = context.read<UserCubit>().state.code;
    context.read<CoursesCubit>().updateCourseProgress(
      courseId,
      userCode: userCode,
    );
  }

  IconData _getCourseIcon(String image) {
    switch (image) {
      case 'physics':
        return Icons.science;
      case 'chemistry':
        return Icons.science_outlined;
      case 'math':
        return Icons.calculate;
      case 'programming':
        return Icons.code;
      default:
        return Icons.menu_book;
    }
  }
}
