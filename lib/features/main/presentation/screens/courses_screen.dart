import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  // بيانات وهمية للكورسات - قدرات كمي
  static final List<Map<String, dynamic>> courses = [
    {
      'id': '1',
      'title': 'دورة تأسيس قدرات كمي - الجزء الأول',
      'description': 'دورة تأسيسية شاملة تغطي الأساسيات في القدرات الكمية',
      'instructor': 'د. أحمد محمد',
      'lessonsCount': 15,
      'duration': '20 ساعة',
      'progress': 60,
      'image': 'math',
      'color': 0xFF6366F1,
    },
    {
      'id': '2',
      'title': 'دورة تأسيس قدرات كمي - الجزء الثاني',
      'description': 'استكمال دورة التأسيس مع التركيز على التطبيقات العملية',
      'instructor': 'د. سارة علي',
      'lessonsCount': 20,
      'duration': '25 ساعة',
      'progress': 30,
      'image': 'math',
      'color': 0xFF8B5CF6,
    },
    {
      'id': '3',
      'title': 'دورة قدرات كمي - المستوى المتقدم',
      'description': 'دورة متقدمة للطلاب الذين أكملوا التأسيس',
      'instructor': 'د. خالد حسن',
      'lessonsCount': 18,
      'duration': '22 ساعة',
      'progress': 0,
      'image': 'math',
      'color': 0xFF10B981,
    },
    {
      'id': '4',
      'title': 'دورة قدرات كمي - حل المسائل',
      'description': 'دورة متخصصة في حل المسائل المعقدة في القدرات الكمية',
      'instructor': 'م. محمد ناجي',
      'lessonsCount': 12,
      'duration': '15 ساعة',
      'progress': 45,
      'image': 'math',
      'color': 0xFF3B82F6,
    },
    {
      'id': '5',
      'title': 'دورة تأسيس قدرات كمي - الجزء الثالث',
      'description': 'استكمال دورة التأسيس مع التركيز على المهارات المتقدمة',
      'instructor': 'د. فاطمة أحمد',
      'lessonsCount': 16,
      'duration': '18 ساعة',
      'progress': 0,
      'image': 'math',
      'color': 0xFFF59E0B,
    },
    {
      'id': '6',
      'title': 'دورة قدرات كمي - المراجعة النهائية',
      'description': 'دورة مراجعة شاملة لجميع مواضيع القدرات الكمية',
      'instructor': 'د. يوسف خالد',
      'lessonsCount': 10,
      'duration': '12 ساعة',
      'progress': 0,
      'image': 'math',
      'color': 0xFFEF4444,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: CoursesScreen.courses.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: CoursesScreen.courses.length,
              itemBuilder: (context, index) {
                return _buildCourseCard(context, CoursesScreen.courses[index]);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 80, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'لا توجد كورسات متاحة حالياً',
            style: AppStyles.textSecondaryStyle.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, Map<String, dynamic> course) {
    final color = Color(course['color'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // الانتقال لصفحة فيديوهات الكورس
            context.push(
              '${AppRouters.courseVideosScreen}/${course['id']}',
              extra: course,
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة/أيقونة الكورس
              Container(
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color, color.withOpacity(0.7)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    // أيقونة الكورس
                    Center(
                      child: Icon(
                        _getCourseIcon(course['image'] as String),
                        size: 80,
                        color: AppColors.secondaryColor.withOpacity(0.3),
                      ),
                    ),
                    // شريط التقدم
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor.withOpacity(0.2),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (course['progress'] as int) / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.secondaryColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // محتوى الكورس
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان
                    Text(
                      course['title'] as String,
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // الوصف
                    Text(
                      course['description'] as String,
                      style: AppStyles.textSecondaryStyle.copyWith(
                        fontSize: 13,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // معلومات الكورس
                    Row(
                      children: [
                        _buildInfoChip(
                          icon: Icons.person_outline,
                          text: course['instructor'] as String,
                        ),
                        const SizedBox(width: 8),
                        _buildInfoChip(
                          icon: Icons.play_circle_outline,
                          text: '${course['lessonsCount']} درس',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // التقدم والمدة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // شريط التقدم
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'التقدم',
                                    style: AppStyles.textSecondaryStyle
                                        .copyWith(fontSize: 12),
                                  ),
                                  Text(
                                    '${course['progress']}%',
                                    style: AppStyles.textSecondaryStyle
                                        .copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: color,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (course['progress'] as int) / 100,
                                  backgroundColor: AppColors.borderLight,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    color,
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // المدة
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.access_time, size: 14, color: color),
                              const SizedBox(width: 4),
                              Text(
                                course['duration'] as String,
                                style: AppStyles.textSecondaryStyle.copyWith(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
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
    );
  }

  Widget _buildInfoChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppStyles.textSecondaryStyle.copyWith(fontSize: 12),
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
