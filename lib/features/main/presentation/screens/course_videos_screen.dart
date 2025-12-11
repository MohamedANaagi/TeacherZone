import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../widgets/video_item_widget.dart';

class CourseVideosScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseVideosScreen({super.key, required this.course});

  // بيانات وهمية للفيديوهات - قدرات كمي
  List<Map<String, dynamic>> get videos {
    final courseId = course['id'] as String;

    // فيديوهات مختلفة حسب الكورس
    if (courseId == '1') {
      return [
        {
          'id': '1',
          'title': 'مقدمة في القدرات الكمية',
          'duration': '15:30',
          'isWatched': true,
          'order': 1,
          'hasQuiz': true, // يوجد نموذج للفيديو
        },
        {
          'id': '2',
          'title': 'الأعداد والعمليات الحسابية',
          'duration': '22:45',
          'isWatched': true,
          'order': 2,
          'hasQuiz': true,
        },
        {
          'id': '3',
          'title': 'الكسور والعمليات عليها',
          'duration': '18:20',
          'isWatched': false,
          'order': 3,
          'hasQuiz': false,
        },
        {
          'id': '4',
          'title': 'النسب والتناسب',
          'duration': '25:10',
          'isWatched': false,
          'order': 4,
          'hasQuiz': true,
        },
        {
          'id': '5',
          'title': 'المعادلات الخطية',
          'duration': '20:00',
          'isWatched': false,
          'order': 5,
          'hasQuiz': false,
        },
      ];
    } else if (courseId == '2') {
      return [
        {
          'id': '1',
          'title': 'الهندسة الأساسية',
          'duration': '18:00',
          'isWatched': true,
          'order': 1,
          'hasQuiz': true,
        },
        {
          'id': '2',
          'title': 'المساحات والأحجام',
          'duration': '24:30',
          'isWatched': true,
          'order': 2,
          'hasQuiz': false,
        },
        {
          'id': '3',
          'title': 'الزوايا والمثلثات',
          'duration': '19:15',
          'isWatched': false,
          'order': 3,
          'hasQuiz': true,
        },
      ];
    } else if (courseId == '3') {
      return [
        {
          'id': '1',
          'title': 'المعادلات المعقدة',
          'duration': '20:00',
          'isWatched': false,
          'order': 1,
          'hasQuiz': true,
        },
        {
          'id': '2',
          'title': 'المتباينات',
          'duration': '22:00',
          'isWatched': false,
          'order': 2,
          'hasQuiz': false,
        },
        {
          'id': '3',
          'title': 'الدوال والرسوم البيانية',
          'duration': '25:00',
          'isWatched': false,
          'order': 3,
          'hasQuiz': true,
        },
      ];
    } else if (courseId == '4') {
      return [
        {
          'id': '1',
          'title': 'استراتيجيات حل المسائل',
          'duration': '15:00',
          'isWatched': false,
          'order': 1,
          'hasQuiz': true,
        },
        {
          'id': '2',
          'title': 'المسائل الكلامية',
          'duration': '18:00',
          'isWatched': false,
          'order': 2,
          'hasQuiz': false,
        },
        {
          'id': '3',
          'title': 'المسائل المعقدة',
          'duration': '20:00',
          'isWatched': false,
          'order': 3,
          'hasQuiz': true,
        },
      ];
    } else if (courseId == '5') {
      return [
        {
          'id': '1',
          'title': 'مراجعة الأعداد والعمليات',
          'duration': '16:00',
          'isWatched': false,
          'order': 1,
          'hasQuiz': false,
        },
        {
          'id': '2',
          'title': 'مراجعة الهندسة',
          'duration': '19:00',
          'isWatched': false,
          'order': 2,
          'hasQuiz': true,
        },
        {
          'id': '3',
          'title': 'مراجعة الجبر',
          'duration': '21:00',
          'isWatched': false,
          'order': 3,
          'hasQuiz': true,
        },
      ];
    } else if (courseId == '6') {
      return [
        {
          'id': '1',
          'title': 'المراجعة الشاملة - الجزء الأول',
          'duration': '22:00',
          'isWatched': false,
          'order': 1,
          'hasQuiz': true,
        },
        {
          'id': '2',
          'title': 'المراجعة الشاملة - الجزء الثاني',
          'duration': '24:00',
          'isWatched': false,
          'order': 2,
          'hasQuiz': false,
        },
        {
          'id': '3',
          'title': 'نصائح قبل الامتحان',
          'duration': '15:00',
          'isWatched': false,
          'order': 3,
          'hasQuiz': false,
        },
      ];
    } else {
      return [
        {
          'id': '1',
          'title': 'الدرس الأول',
          'duration': '10:00',
          'isWatched': false,
          'order': 1,
          'hasQuiz': false,
        },
        {
          'id': '2',
          'title': 'الدرس الثاني',
          'duration': '12:30',
          'isWatched': false,
          'order': 2,
          'hasQuiz': true,
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(course['color'] as int);

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
                        _getCourseIcon(course['image'] as String),
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
                            course['title'] as String,
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
                                course['instructor'] as String,
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
                          value: '${course['lessonsCount']}',
                          color: color,
                        ),
                        const SizedBox(width: 24),
                        _buildInfoItem(
                          icon: Icons.access_time,
                          label: 'المدة',
                          value: course['duration'] as String,
                          color: color,
                        ),
                        const SizedBox(width: 24),
                        _buildInfoItem(
                          icon: Icons.trending_up,
                          label: 'التقدم',
                          value: '${course['progress']}%',
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
                  ...videos.map(
                    (video) => RepaintBoundary(
                      child: VideoItemWidget(
                        video: video,
                        courseColor: color,
                        onTap: () {
                          _showVideoDialog(context, video, color);
                        },
                      ),
                    ),
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
