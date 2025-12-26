import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/live_lesson.dart';
import '../../data/repositories/live_lesson_repository_impl.dart';
import '../../data/datasources/live_lesson_remote_datasource.dart';
import '../../domain/usecases/get_live_lessons_usecase.dart';
import '../widgets/live_lesson_card_widget.dart';
import '../../../../../features/main/presentation/widgets/primary_app_bar.dart';
import '../../../../../features/user/presentation/cubit/user_cubit.dart';

class LiveLessonsScreen extends StatefulWidget {
  const LiveLessonsScreen({super.key});

  @override
  State<LiveLessonsScreen> createState() => _LiveLessonsScreenState();
}

class _LiveLessonsScreenState extends State<LiveLessonsScreen> {
  Future<List<LiveLesson>>? _liveLessonsFuture;
  late final GetLiveLessonsUseCase _getLiveLessonsUseCase;
  Timer? _updateTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Initialize repository and use case
    final repository = LiveLessonRepositoryImpl(
      remoteDataSource: LiveLessonRemoteDataSourceImpl(),
    );
    _getLiveLessonsUseCase = GetLiveLessonsUseCase(repository);
    _loadLiveLessons();
    _startAutoUpdate();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  /// بدء التحديث التلقائي للشاشة كل دقيقة
  /// لضمان تحديث حالة الدروس المباشرة عندما يبدأ أو ينتهي درس
  void _startAutoUpdate() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadLiveLessons() async {
    try {
      // الحصول على userCode من UserCubit
      final userState = context.read<UserCubit>().state;
      final userCode = userState.code;
      
      String? adminCode;
      
      // إذا كان هناك userCode، جلب adminCode المرتبط به
      if (userCode != null && userCode.isNotEmpty) {
        final codeModel = await InjectionContainer.adminRepo.getCodeByCode(userCode);
        adminCode = codeModel?.adminCode;
      }
      
      // جلب الدروس المباشرة للـ adminCode المحدد فقط
      setState(() {
        _liveLessonsFuture = _getLiveLessonsUseCase(adminCode: adminCode).catchError((e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('فشل جلب الدروس المباشرة: ${e.toString()}'),
                backgroundColor: AppColors.errorColor,
              ),
            );
          }
          return <LiveLesson>[];
        });
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل جلب الدروس المباشرة: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      setState(() {
        _liveLessonsFuture = Future.value(<LiveLesson>[]);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = isWeb && screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: PrimaryAppBar(title: 'الدروس المباشرة'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _loadLiveLessons();
            await _liveLessonsFuture;
          },
          child: FutureBuilder<List<LiveLesson>>(
            future: _liveLessonsFuture ?? Future.value(<LiveLesson>[]),
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
                            'حدث خطأ في جلب الدروس المباشرة',
                            style: AppStyles.textSecondaryStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadLiveLessons,
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final liveLessons = snapshot.data ?? [];

                // Filter to show only upcoming and recent lessons (within last 48 hours from end time)
                // Use _currentTime to trigger rebuild when timer updates
                final now = _currentTime;
                final filteredLessons = liveLessons.where((lesson) {
                  final difference = lesson.endTime.difference(now);
                  // Show if upcoming or ended within last 48 hours
                  return difference.inHours >= -48;
                }).toList();

                // Sort lessons: live/upcoming first, then ended lessons
                filteredLessons.sort((a, b) {
                  final aIsEnded = a.isEnded(now);
                  final bIsEnded = b.isEnded(now);
                  
                  // Live/upcoming lessons come first
                  if (aIsEnded != bIsEnded) {
                    return aIsEnded ? 1 : -1;
                  }
                  
                  // For same category, sort by time (closest first)
                  if (!aIsEnded) {
                    // Upcoming/Live: earliest scheduled time first
                    return a.scheduledTime.compareTo(b.scheduledTime);
                  } else {
                    // Ended: most recent end time first
                    return b.endTime.compareTo(a.endTime);
                  }
                });

                if (filteredLessons.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.video_call_outlined,
                            size: 60,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد دروس مباشرة متاحة',
                            style: AppStyles.textSecondaryStyle.copyWith(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // تصميم متجاوب للويب والموبايل
                if (isDesktop) {
                  // Grid Layout للويب
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth > 1400 ? 3 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.7, // نسبة مناسبة للدروس المباشرة
                      ),
                      itemCount: filteredLessons.length,
                      itemBuilder: (context, index) {
                        return RepaintBoundary(
                          child: LiveLessonCardWidget(
                            liveLesson: filteredLessons[index],
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  // List Layout للموبايل
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredLessons.length,
                    cacheExtent: 200,
                    itemBuilder: (context, index) {
                      return RepaintBoundary(
                        child: LiveLessonCardWidget(
                          liveLesson: filteredLessons[index],
                        ),
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
}

