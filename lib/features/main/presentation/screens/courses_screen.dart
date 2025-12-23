import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';
import '../../../courses/presentation/cubit/courses_cubit.dart';
import '../../../courses/presentation/cubit/courses_state.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  bool _hasLoadedCourses = false;

  @override
  void initState() {
    super.initState();
    // تحميل الكورسات مع الكود عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCoursesIfReady();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة تحميل الكورسات عند تغيير dependencies (مثل reload في الويب)
    if (!_hasLoadedCourses) {
      _loadCoursesIfReady();
    }
  }

  void _loadCoursesIfReady() {
    if (!mounted || _hasLoadedCourses) return;
    
    final userState = context.read<UserCubit>().state;
    final code = userState.code;
    final adminCode = userState.adminCode;
    
    // التأكد من أن البيانات محملة (إما code أو adminCode موجود)
    if (code != null || adminCode != null) {
      debugPrint('📚 تحميل الكورسات - code: $code, adminCode: $adminCode');
      context.read<CoursesCubit>().loadCourses(userCode: code, adminCode: adminCode);
      _hasLoadedCourses = true;
    } else {
      debugPrint('⏳ انتظار تحميل بيانات المستخدم...');
      // إعادة المحاولة بعد قليل
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_hasLoadedCourses) {
          _loadCoursesIfReady();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocListener<UserCubit, UserState>(
          listener: (context, userState) {
            // عند تغيير بيانات المستخدم، إعادة تحميل الكورسات
            final code = userState.code;
            final adminCode = userState.adminCode;
            if (code != null || adminCode != null) {
              _hasLoadedCourses = false;
              _loadCoursesIfReady();
            }
          },
          child: BlocBuilder<CoursesCubit, CoursesState>(
            builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: AppStyles.textSecondaryStyle.copyWith(
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final userState = context.read<UserCubit>().state;
                        final userCode = userState.code;
                        final adminCode = userState.adminCode;
                        context.read<CoursesCubit>().loadCourses(
                          userCode: userCode,
                          adminCode: adminCode,
                        );
                      },
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (state.courses.isEmpty) {
              return _buildEmptyState();
            }

            // تصميم متجاوب للويب
            final isWeb = kIsWeb;
            final screenWidth = MediaQuery.of(context).size.width;
            final isDesktop = isWeb && screenWidth > 800;
            
            if (isDesktop) {
              // Grid Layout للويب
              return Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: screenWidth > 1400 ? 3 : 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.85, // تقليل النسبة لإعطاء مساحة أكبر للارتفاع
                  ),
                  itemCount: state.courses.length,
                  itemBuilder: (context, index) {
                    return RepaintBoundary(
                      child: _buildCourseCard(context, state.courses[index]),
                    );
                  },
                ),
              );
            } else {
              // List Layout للموبايل
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.courses.length,
                cacheExtent: 200,
                itemBuilder: (context, index) {
                  return RepaintBoundary(
                    child: _buildCourseCard(context, state.courses[index]),
                  );
                },
              );
            }
          },
          ),
        ),
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
          onTap: () async {
            // الانتقال لصفحة فيديوهات الكورس
            await context.push(
              '${AppRouters.courseVideosScreen}/${course['id']}',
              extra: course,
            );
            // عند الرجوع من شاشة الفيديوهات، حدّث التقدم
            if (mounted) {
              final userCode = context.read<UserCubit>().state.code;
              context.read<CoursesCubit>().updateCourseProgress(
                course['id'] as String,
                userCode: userCode,
              );
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: ClipRect(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // صورة/أيقونة الكورس
                Container(
                  height: 160, // تقليل الارتفاع من 180 إلى 160
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
                  padding: const EdgeInsets.all(12), // تقليل padding من 16 إلى 12
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان
                      Text(
                        course['title'] as String,
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 16, // تقليل حجم الخط من 18 إلى 16
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6), // تقليل المسافة من 8 إلى 6
                      // الوصف
                      Text(
                        course['description'] as String,
                        style: AppStyles.textSecondaryStyle.copyWith(
                          fontSize: 12, // تقليل حجم الخط من 13 إلى 12
                          height: 1.3, // تقليل height من 1.4 إلى 1.3
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10), // تقليل المسافة من 12 إلى 10
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
                    const SizedBox(height: 10), // تقليل المسافة من 12 إلى 10
                    // التقدم والمدة
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // شريط التقدم
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
