import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../videos/presentation/cubit/videos_cubit.dart';
import '../../../videos/presentation/cubit/videos_state.dart';
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
        context.read<VideosCubit>().loadCourseVideos(courseId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseId = widget.course['id'] as String;
    final color = Color(widget.course['color'] as int);

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
                          value: '${widget.course['progress']}%',
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
                                    context
                                        .read<VideosCubit>()
                                        .loadCourseVideos(courseId);
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
                                  onTap: () {
                                    _showVideoDialog(context, video, color);
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

  void _showVideoDialog(
    BuildContext context,
    Map<String, dynamic> video,
    Color courseColor,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(video['title'] as String, style: AppStyles.subHeadingStyle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: courseColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Icon(
                  Icons.play_circle_filled,
                  size: 80,
                  color: courseColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'سيتم فتح الفيديو قريباً',
              style: AppStyles.textSecondaryStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إغلاق', style: TextStyle(color: courseColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: فتح الفيديو
            },
            style: ElevatedButton.styleFrom(backgroundColor: courseColor),
            child: const Text(
              'تشغيل',
              style: TextStyle(color: AppColors.secondaryColor),
            ),
          ),
        ],
      ),
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
