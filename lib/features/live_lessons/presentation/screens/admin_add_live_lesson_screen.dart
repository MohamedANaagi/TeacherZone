import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/errors/exceptions.dart';
import '../../domain/entities/live_lesson.dart';
import '../../../../../features/admin/presentation/widgets/admin_app_bar.dart';
import '../../../../../features/auth/presentation/widgets/custom_text_field.dart';
import '../../../../../features/user/presentation/cubit/user_cubit.dart';
import '../../data/repositories/live_lesson_repository_impl.dart';
import '../../data/datasources/live_lesson_remote_datasource.dart';
import '../../domain/usecases/add_live_lesson_usecase.dart';
import '../../domain/usecases/get_live_lessons_usecase.dart';
import '../../domain/usecases/delete_live_lesson_usecase.dart';

class AdminAddLiveLessonScreen extends StatefulWidget {
  const AdminAddLiveLessonScreen({super.key});

  @override
  State<AdminAddLiveLessonScreen> createState() =>
      _AdminAddLiveLessonScreenState();
}

class _AdminAddLiveLessonScreenState extends State<AdminAddLiveLessonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _meetingLinkController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _selectedDurationHours = 1; // Default 1 hour
  int _selectedDurationMinutes = 0; // Default 0 minutes (must be multiple of 5)
  bool _isLoading = false;
  Future<List<LiveLesson>>? _liveLessonsFuture;

  // Create repository instance
  late final LiveLessonRepositoryImpl _liveLessonRepository;
  late final AddLiveLessonUseCase _addLiveLessonUseCase;
  late final GetLiveLessonsUseCase _getLiveLessonsUseCase;
  late final DeleteLiveLessonUseCase _deleteLiveLessonUseCase;

  @override
  void initState() {
    super.initState();
    // Initialize repository and use cases
    _liveLessonRepository = LiveLessonRepositoryImpl(
      remoteDataSource: LiveLessonRemoteDataSourceImpl(),
    );
    _addLiveLessonUseCase = AddLiveLessonUseCase(_liveLessonRepository);
    _getLiveLessonsUseCase = GetLiveLessonsUseCase(_liveLessonRepository);
    _deleteLiveLessonUseCase = DeleteLiveLessonUseCase(_liveLessonRepository);
    _loadLiveLessons();
    _startAutoUpdate();
  }

  Timer? _updateTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _meetingLinkController.dispose();
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

  Future<List<LiveLesson>> _getAdminCodeAndLoadLiveLessons() async {
    final adminCode = context.read<UserCubit>().state.adminCode;
    return await _getLiveLessonsUseCase(adminCode: adminCode);
  }

  void _loadLiveLessons() {
    setState(() {
      _liveLessonsFuture = _getAdminCodeAndLoadLiveLessons().catchError((e) {
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
  }

  Future<void> _selectDate() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        // Reset time if date changed
        if (_selectedTime == null) {
          _selectedTime = TimeOfDay.now();
        }
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime? _getScheduledDateTime() {
    if (_selectedDate != null && _selectedTime != null) {
      return DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }
    return null;
  }

  Future<void> _addLiveLesson() async {
    if (!_formKey.currentState!.validate()) return;

    final scheduledDateTime = _getScheduledDateTime();
    if (scheduledDateTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء تحديد تاريخ ووقت الدرس'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return;
    }

    if (scheduledDateTime.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('وقت الدرس يجب أن يكون في المستقبل'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final adminCode = context.read<UserCubit>().state.adminCode;
      if (adminCode == null || adminCode.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('كود الأدمن غير موجود. يجب تسجيل الدخول بكود أدمن أولاً'),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // حساب المدة الإجمالية بالدقائق
      final totalDurationMinutes = (_selectedDurationHours * 60) + _selectedDurationMinutes;
      
      await _addLiveLessonUseCase(
        title: _titleController.text,
        description: _descriptionController.text,
        meetingLink: _meetingLinkController.text,
        scheduledTime: scheduledDateTime,
        durationMinutes: totalDurationMinutes,
        adminCode: adminCode,
      );

      _titleController.clear();
      _descriptionController.clear();
      _meetingLinkController.clear();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _selectedDurationHours = 1; // Reset to default
        _selectedDurationMinutes = 0; // Reset to default
      });

      // إعادة تحميل قائمة الدروس المباشرة
      _loadLiveLessons();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة الدرس المباشر بنجاح'),
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

  Future<void> _deleteLiveLesson(String liveLessonId) async {
    try {
      await _deleteLiveLessonUseCase(liveLessonId);

      // إعادة تحميل قائمة الدروس المباشرة
      _loadLiveLessons();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الدرس المباشر بنجاح'),
            backgroundColor: AppColors.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف الدرس المباشر: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final date = '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}';
    final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }

  String _calculateTotalDuration() {
    final totalMinutes = (_selectedDurationHours * 60) + _selectedDurationMinutes;
    if (totalMinutes == 0) {
      return '0 دقيقة';
    } else if (totalMinutes < 60) {
      return '$totalMinutes دقيقة';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      if (minutes == 0) {
        return '$hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
      } else {
        return '$hours ${hours == 1 ? 'ساعة' : 'ساعات'} و $minutes دقيقة';
      }
    }
  }

  Widget _buildLiveLessonCard(LiveLesson liveLesson, {required bool isDesktop}) {
    // Use _currentTime to trigger rebuild when timer updates
    final now = _currentTime;
    final isEnded = liveLesson.isEnded(now);
    final isPast = liveLesson.scheduledTime.isBefore(now);

    return Container(
      margin: EdgeInsets.only(bottom: isDesktop ? 0 : 12),
      padding: EdgeInsets.all(isDesktop ? 16 : 16),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(isDesktop ? 20 : 16),
        border: Border.all(
          color: isEnded
              ? AppColors.errorColor.withOpacity(0.3)
              : isPast
                  ? AppColors.warningColor.withOpacity(0.3)
                  : AppColors.borderColor,
          width: isEnded || isPast ? 2 : 1,
        ),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      liveLesson.title,
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: isDesktop ? 18 : 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      liveLesson.description,
                      style: AppStyles.textSecondaryStyle.copyWith(
                        fontSize: isDesktop ? 14 : 13,
                      ),
                      maxLines: isDesktop ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            _formatDateTime(liveLesson.scheduledTime),
                            style: AppStyles.textSecondaryStyle.copyWith(
                              fontSize: 12,
                              color: isPast
                                  ? AppColors.errorColor
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'المدة: ${liveLesson.durationMinutes} دقيقة',
                          style: AppStyles.textSecondaryStyle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // زر الحذف
              IconButton(
                onPressed: () => _deleteLiveLesson(liveLesson.id),
                icon: const Icon(Icons.delete_outline),
                color: AppColors.errorColor,
                tooltip: 'حذف الدرس',
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = isWeb && screenWidth > 800;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AdminAppBar(title: 'إضافة دروس مباشرة'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 24.0 : 16.0),
        child: ConstrainedBox(
          constraints: isDesktop
              ? const BoxConstraints(maxWidth: 800)
              : const BoxConstraints(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // نموذج إضافة درس مباشر جديد
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
                        'إضافة درس مباشر جديد',
                        style: AppStyles.subHeadingStyle.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // حقل العنوان
                      CustomTextField(
                        controller: _titleController,
                        hintText: 'عنوان الدرس المباشر',
                        icon: Icons.title,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال عنوان الدرس المباشر';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // حقل الوصف
                      CustomTextField(
                        controller: _descriptionController,
                        hintText: 'وصف الدرس المباشر',
                        icon: Icons.description,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال وصف الدرس المباشر';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // حقل رابط الدرس
                      CustomTextField(
                        controller: _meetingLinkController,
                        hintText: 'رابط الدرس (Zoom أو Google Meet)',
                        icon: Icons.link,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        keyboardType: TextInputType.url,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'الرجاء إدخال رابط الدرس';
                          }
                          if (!value.startsWith('http://') &&
                              !value.startsWith('https://')) {
                            return 'الرابط يجب أن يكون رابطاً صحيحاً';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // اختيار التاريخ والوقت
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedDate == null
                                            ? 'اختر التاريخ'
                                            : '${_selectedDate!.year}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.day.toString().padLeft(2, '0')}',
                                        style: AppStyles.textSecondaryStyle
                                            .copyWith(
                                          color: _selectedDate == null
                                              ? AppColors.textLight
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.backgroundLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.borderColor,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        _selectedTime == null
                                            ? 'اختر الوقت'
                                            : '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                                        style: AppStyles.textSecondaryStyle
                                            .copyWith(
                                          color: _selectedTime == null
                                              ? AppColors.textLight
                                              : AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // اختيار مدة الدرس بالساعات والدقائق
                      Row(
                        children: [
                          // اختيار الساعات
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedDurationHours,
                              decoration: InputDecoration(
                                labelText: 'الساعات',
                                prefixIcon: const Icon(Icons.timer),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                              ),
                              items: List.generate(5, (index) {
                                return DropdownMenuItem(
                                  value: index,
                                  child: Text('$index ${index == 0 ? 'ساعة' : index == 1 ? 'ساعة' : 'ساعات'}'),
                                );
                              }),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedDurationHours = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          // اختيار الدقائق (بزيادات 5)
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedDurationMinutes,
                              decoration: InputDecoration(
                                labelText: 'الدقائق',
                                prefixIcon: const Icon(Icons.timer_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.backgroundLight,
                              ),
                              items: List.generate(12, (index) {
                                final minutes = index * 5; // 0, 5, 10, 15, ..., 55
                                return DropdownMenuItem(
                                  value: minutes,
                                  child: Text('$minutes دقيقة'),
                                );
                              }),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedDurationMinutes = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // عرض المدة الإجمالية
                      Text(
                        'المدة الإجمالية: ${_calculateTotalDuration()}',
                        style: AppStyles.textSecondaryStyle.copyWith(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // زر الإضافة
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addLiveLesson,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
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
                                  'إضافة الدرس المباشر',
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
              // قائمة الدروس المباشرة المضافة
              FutureBuilder<List<LiveLesson>>(
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
                          ],
                        ),
                      ),
                    );
                  }

                  final liveLessons = snapshot.data ?? [];

                  if (liveLessons.isEmpty) {
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
                              'لا توجد دروس مباشرة مضافة',
                              style: AppStyles.textSecondaryStyle
                                  .copyWith(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  // تصميم متجاوب للويب والموبايل
                  if (isDesktop) {
                    // Grid Layout للويب
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الدروس المباشرة المضافة (${liveLessons.length})',
                          style: AppStyles.subHeadingStyle.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: screenWidth > 1400 ? 3 : 2,
                            crossAxisSpacing: 20,
                            mainAxisSpacing: 20,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: liveLessons.length,
                          itemBuilder: (context, index) {
                            return _buildLiveLessonCard(
                              liveLessons[index],
                              isDesktop: true,
                            );
                          },
                        ),
                      ],
                    );
                  } else {
                    // List Layout للموبايل
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الدروس المباشرة المضافة (${liveLessons.length})',
                          style: AppStyles.subHeadingStyle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: liveLessons.length,
                          itemBuilder: (context, index) {
                            return _buildLiveLessonCard(
                              liveLessons[index],
                              isDesktop: false,
                            );
                          },
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

