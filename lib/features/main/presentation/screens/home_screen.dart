import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/services/video_progress_service.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';
import '../../../courses/presentation/cubit/courses_cubit.dart';
import '../../../courses/presentation/cubit/courses_state.dart';
import '../../../exams/presentation/cubit/exams_cubit.dart';
import '../../../exams/presentation/cubit/exams_state.dart';
import '../widgets/user_card_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/feature_card_widget.dart';
import '../widgets/welcome_section_widget.dart';

/// الشاشة الرئيسية للتطبيق
/// تعرض معلومات المستخدم، إحصائيات سريعة، وميزات المنصة
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الكورسات والاختبارات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final userCode = context.read<UserCubit>().state.code;
        context.read<CoursesCubit>().loadCourses(userCode: userCode);
        context.read<ExamsCubit>().loadExams();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // بطاقة المستخدم في الأعلى
              _buildUserCard(),
              const SizedBox(height: 24),

              // قسم تعريف عن المحتوى
              const WelcomeSectionWidget(),
              const SizedBox(height: 24),

              // إحصائيات سريعة
              _buildStatsSection(),
              const SizedBox(height: 24),

              // قسم الميزات
              _buildFeaturesSection(),
            ],
          ),
        ),
      ),
    );
  }

  /// بناء بطاقة المستخدم
  /// تعرض معلومات المستخدم (الاسم، رقم الهاتف، الصورة، الأيام المتبقية)
  /// تستخدم BlocBuilder للتحديث التلقائي عند تغيير بيانات المستخدم
  Widget _buildUserCard() {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) =>
          previous.name != current.name ||
          previous.phone != current.phone ||
          previous.imagePath != current.imagePath ||
          previous.subscriptionEndDate != current.subscriptionEndDate,
      builder: (context, state) {
        return UserCardWidget(state: state);
      },
    );
  }

  /// بناء قسم الإحصائيات
  /// يعرض ثلاثة بطاقات إحصائية: الدروس المكتملة، الكورسات النشطة، الاختبارات
  Widget _buildStatsSection() {
    return BlocBuilder<UserCubit, UserState>(
      buildWhen: (previous, current) => previous.code != current.code,
      builder: (context, userState) {
        return BlocBuilder<CoursesCubit, CoursesState>(
          buildWhen: (previous, current) => previous.courses != current.courses,
          builder: (context, coursesState) {
            return BlocBuilder<ExamsCubit, ExamsState>(
              buildWhen: (previous, current) =>
                  previous.exams.length != current.exams.length,
              builder: (context, examsState) {
                return _StatsCards(
                  key: ValueKey(
                      '${userState.code}_${coursesState.courses.length}'),
                  userCode: userState.code,
                  courses: coursesState.courses,
                  examsCount: examsState.exams.length,
                );
              },
            );
          },
        );
      },
    );
  }

  /// بناء قسم الميزات
  /// يعرض قائمة بالميزات المتاحة في المنصة (دروس فيديو، اختبارات، تتبع التقدم)
  Widget _buildFeaturesSection() {
    // بيانات الميزات - يمكن تحويلها إلى Cubit في المستقبل
    final features = [
      {
        'icon': Icons.video_library,
        'title': 'دروس فيديو',
        'description': 'محتوى تعليمي عالي الجودة',
      },
      {
        'icon': Icons.quiz,
        'title': 'اختبارات تفاعلية',
        'description': 'اختبر معلوماتك بسهولة',
      },
      {
        'icon': Icons.track_changes,
        'title': 'تتبع التقدم',
        'description': 'راقب تقدمك في التعلم',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان القسم
        Text(
          'مميزات المنصة',
          style: AppStyles.headingStyle.copyWith(fontSize: 22),
        ),
        const SizedBox(height: 16),
        // قائمة الميزات
        ...features.map((feature) {
          return FeatureCardWidget(
            icon: feature['icon'] as IconData,
            title: feature['title'] as String,
            description: feature['description'] as String,
          );
        }).toList(),
      ],
    );
  }
}

/// Widget لعرض بطاقات الإحصائيات مع البيانات الفعلية
class _StatsCards extends StatefulWidget {
  final String? userCode;
  final List<Map<String, dynamic>> courses;
  final int examsCount;

  const _StatsCards({
    super.key,
    required this.userCode,
    required this.courses,
    required this.examsCount,
  });

  @override
  State<_StatsCards> createState() => _StatsCardsState();
}

class _StatsCardsState extends State<_StatsCards> {
  int _completedLessons = 0;
  int _activeCourses = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didUpdateWidget(_StatsCards oldWidget) {
    super.didUpdateWidget(oldWidget);
    // إعادة تحميل الإحصائيات عند تغيير الكود أو الكورسات أو التقدم
    if (oldWidget.userCode != widget.userCode ||
        oldWidget.courses.length != widget.courses.length ||
        _hasProgressChanged(oldWidget.courses, widget.courses)) {
      _loadStats();
    }
  }

  /// التحقق من تغيير التقدم في أي كورس
  bool _hasProgressChanged(
    List<Map<String, dynamic>> oldCourses,
    List<Map<String, dynamic>> newCourses,
  ) {
    if (oldCourses.length != newCourses.length) return true;
    
    for (int i = 0; i < oldCourses.length; i++) {
      final oldProgress = oldCourses[i]['progress'] as int;
      final newProgress = newCourses[i]['progress'] as int;
      if (oldProgress != newProgress) return true;
    }
    
    return false;
  }

  Future<void> _loadStats() async {
    if (widget.userCode == null || widget.userCode!.isEmpty) {
      setState(() {
        _completedLessons = 0;
        _activeCourses = 0;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // حساب عدد الدروس المكتملة والكورسات النشطة
      int completedLessons = 0;
      int activeCourses = 0;

      for (final course in widget.courses) {
        final courseId = course['id'] as String;
        
        // جلب الفيديوهات المشاهدة للكورس
        final watchedVideos = await VideoProgressService
            .getWatchedVideosForCourse(
          code: widget.userCode!,
          courseId: courseId,
        );
        
        // إضافة عدد الفيديوهات المشاهدة للدروس المكتملة
        completedLessons += watchedVideos.length;
        
        // إذا كان هناك فيديوهات مشاهدة، الكورس نشط
        if (watchedVideos.isNotEmpty) {
          activeCourses++;
        }
      }

      if (mounted) {
        setState(() {
          _completedLessons = completedLessons;
          _activeCourses = activeCourses;
          _isLoading = false;
        });
        
        debugPrint(
          'الإحصائيات: $completedLessons درس مكتمل، $activeCourses كورسات نشطة',
        );
      }
    } catch (e) {
      debugPrint('خطأ في تحميل الإحصائيات: $e');
      if (mounted) {
        setState(() {
          _completedLessons = 0;
          _activeCourses = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Row(
        children: [
          Expanded(
            child: StatCardWidget(
              icon: Icons.play_circle_filled,
              title: '-',
              subtitle: 'درس مكتمل',
              color: AppColors.successColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCardWidget(
              icon: Icons.book,
              title: '-',
              subtitle: 'كورسات نشطة',
              color: AppColors.infoColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCardWidget(
              icon: Icons.quiz,
              title: '${widget.examsCount}',
              subtitle: 'اختبارات',
              color: AppColors.accentColor,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: StatCardWidget(
            icon: Icons.play_circle_filled,
            title: '$_completedLessons',
            subtitle: 'درس مكتمل',
            color: AppColors.successColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCardWidget(
            icon: Icons.book,
            title: '$_activeCourses',
            subtitle: 'كورسات نشطة',
            color: AppColors.infoColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCardWidget(
            icon: Icons.quiz,
            title: '${widget.examsCount}',
            subtitle: 'اختبارات',
            color: AppColors.accentColor,
          ),
        ),
      ],
    );
  }
}
