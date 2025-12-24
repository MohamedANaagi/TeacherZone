import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/di/injection_container.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/test_result.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../exams/presentation/cubit/exams_cubit.dart';

/// شاشة حل الاختبار للطالب
class StudentTestScreen extends StatefulWidget {
  final String testId;
  final String testTitle;
  final Color testColor;

  const StudentTestScreen({
    super.key,
    required this.testId,
    required this.testTitle,
    this.testColor = AppColors.examColor,
  });

  @override
  State<StudentTestScreen> createState() => _StudentTestScreenState();
}

class _StudentTestScreenState extends State<StudentTestScreen> {
  List<Question> _questions = [];
  Map<String, int> _selectedAnswers = {}; // Map<questionId, selectedAnswerIndex>
  int _currentQuestionIndex = 0;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSubmitted = false;
  TestResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkIfTestCompleted();
  }

  /// التحقق من وجود نتيجة للاختبار
  Future<void> _checkIfTestCompleted() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      if (!mounted) return;
      final studentCode = context.read<UserCubit>().state.code;
      if (studentCode == null || studentCode.isEmpty) {
        // إذا لم يكن هناك كود طالب، نسمح بالدخول (مثلاً للأدمن)
        _loadQuestions();
        return;
      }

      // جلب نتائج الاختبارات للطالب
      final results = await InjectionContainer.testRepo
          .getTestResultsByStudentCode(studentCode);

      if (!mounted) return;

      // البحث عن نتيجة هذا الاختبار
      final existingResult = results.where(
        (result) => result.testId == widget.testId,
      ).firstOrNull;

      if (existingResult != null) {
        // إذا وجدت نتيجة، عرضها مباشرة ومنع الدخول
        if (mounted) {
          setState(() {
            _result = existingResult;
            _isSubmitted = true;
            _isLoading = false;
          });
        }
      } else {
        // إذا لم توجد نتيجة، تحميل الأسئلة للسماح بالاختبار
        _loadQuestions();
      }
    } catch (e) {
      // في حالة حدوث خطأ، تحميل الأسئلة للسماح بالاختبار
      debugPrint('خطأ في التحقق من نتيجة الاختبار: $e');
      if (mounted) {
        _loadQuestions();
      }
    }
  }

  Future<void> _loadQuestions() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final questions = await InjectionContainer.testRepo
          .getQuestionsByTestId(widget.testId);
      
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'فشل تحميل الأسئلة: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitTest() async {
    if (_isSubmitting) return;

    // التحقق من أن جميع الأسئلة تم الإجابة عليها
    if (_selectedAnswers.length < _questions.length) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('تنبيه', style: AppStyles.subHeadingStyle),
          content: Text(
            'لم تقم بالإجابة على جميع الأسئلة. هل تريد المتابعة؟',
            style: AppStyles.textPrimaryStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('إلغاء', style: TextStyle(color: widget.testColor)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: widget.testColor),
              child: const Text('متابعة', style: TextStyle(color: AppColors.secondaryColor)),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    setState(() => _isSubmitting = true);

    try {
      final studentCode = context.read<UserCubit>().state.code;
      if (studentCode == null || studentCode.isEmpty) {
        throw Exception('كود الطالب غير موجود');
      }

      final result = await InjectionContainer.submitTestUseCase(
        testId: widget.testId,
        studentCode: studentCode,
        answers: _selectedAnswers,
      );

      if (mounted) {
        setState(() {
          _result = result;
          _isSubmitted = true;
          _isSubmitting = false;
        });

        // تحديث ExamsCubit لإعادة تحميل الاختبارات مع النتيجة الجديدة
        final userState = context.read<UserCubit>().state;
        context.read<ExamsCubit>().loadExams(
          adminCode: userState.adminCode,
          studentCode: userState.code,
        );
      }
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تسليم الاختبار: ${e.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      }
    }
  }

  void _selectAnswer(String questionId, int answerIndex) {
    if (!mounted) return;
    setState(() {
      _selectedAnswers[questionId] = answerIndex;
    });
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('إنهاء الاختبار', style: AppStyles.subHeadingStyle),
        content: Text(
          'هل أنت متأكد من إنهاء الاختبار؟ سيتم فقدان التقدم الحالي.',
          style: AppStyles.textPrimaryStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء', style: TextStyle(color: widget.testColor)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: widget.testColor),
            child: const Text(
              'إنهاء',
              style: TextStyle(color: AppColors.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: widget.testColor,
          title: Text(widget.testTitle, style: AppStyles.subTextStyle),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: widget.testColor,
          title: Text(widget.testTitle, style: AppStyles.subTextStyle),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: AppColors.errorColor),
              const SizedBox(height: 16),
              Text(_error!, style: AppStyles.textSecondaryStyle),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadQuestions,
                style: ElevatedButton.styleFrom(backgroundColor: widget.testColor),
                child: const Text('إعادة المحاولة', style: TextStyle(color: AppColors.secondaryColor)),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: widget.testColor,
          title: Text(widget.testTitle, style: AppStyles.subTextStyle),
        ),
        body: const Center(
          child: Text('لا توجد أسئلة في هذا الاختبار'),
        ),
      );
    }

    if (_isSubmitted && _result != null) {
      return _buildResultScreen();
    }

    return _buildTestScreen();
  }

  Widget _buildTestScreen() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final totalQuestions = _questions.length;
    final progress = (_currentQuestionIndex + 1) / totalQuestions;
    final selectedAnswer = _selectedAnswers[currentQuestion.id];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: widget.testColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: _showExitDialog,
        ),
        title: Text(widget.testTitle, style: AppStyles.subTextStyle.copyWith(fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.secondaryColor.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryColor),
            minHeight: 4,
          ),
        ),
      ),
      body: Column(
        children: [
          // معلومات الاختبار
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.secondaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, color: widget.testColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'السؤال ${_currentQuestionIndex + 1} من $totalQuestions',
                      style: AppStyles.subHeadingStyle.copyWith(fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.testColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: AppStyles.subHeadingStyle.copyWith(
                      fontSize: 14,
                      color: widget.testColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // السؤال
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // نص السؤال و/أو الصورة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (currentQuestion.questionText.isNotEmpty)
                          Text(
                            currentQuestion.questionText,
                            style: AppStyles.subHeadingStyle.copyWith(
                              fontSize: 18,
                              height: 1.5,
                            ),
                          ),
                        if (currentQuestion.imageUrl != null && currentQuestion.imageUrl!.isNotEmpty) ...[
                          if (currentQuestion.questionText.isNotEmpty) const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(maxHeight: 300),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderColor),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                currentQuestion.imageUrl!,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    height: 200,
                                    color: AppColors.backgroundLight,
                                    child: const Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.broken_image, size: 50, color: AppColors.textSecondary),
                                          SizedBox(height: 8),
                                          Text('فشل تحميل الصورة', style: TextStyle(color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    height: 200,
                                    color: AppColors.backgroundLight,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // الخيارات
                  ...List.generate(
                    currentQuestion.options.length,
                    (index) => _buildAnswerOption(
                      currentQuestion.id,
                      index,
                      currentQuestion.options[index],
                      selectedAnswer == index,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // أزرار التنقل
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (!mounted) return;
                        setState(() {
                          _currentQuestionIndex--;
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: widget.testColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'السابق',
                        style: TextStyle(color: widget.testColor),
                      ),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_currentQuestionIndex < _questions.length - 1) {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            } else {
                              _submitTest();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.testColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isSubmitting
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
                            _currentQuestionIndex < _questions.length - 1
                                ? 'التالي'
                                : 'إنهاء الاختبار',
                            style: AppStyles.subTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(
    String questionId,
    int answerIndex,
    String optionText,
    bool isSelected,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectAnswer(questionId, answerIndex),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? widget.testColor.withOpacity(0.1)
                  : AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? widget.testColor : AppColors.borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? widget.testColor : AppColors.borderColor,
                      width: 2,
                    ),
                    color: isSelected
                        ? widget.testColor.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 16, color: widget.testColor)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    optionText,
                    style: AppStyles.textPrimaryStyle.copyWith(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    if (_result == null) return const SizedBox.shrink();

    final percentage = _result!.score.round();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: widget.testColor,
        title: Text('نتيجة الاختبار', style: AppStyles.subTextStyle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // بطاقة النتيجة
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [widget.testColor, widget.testColor.withOpacity(0.7)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.testColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    percentage >= 70
                        ? Icons.emoji_events
                        : percentage >= 50
                            ? Icons.sentiment_satisfied
                            : Icons.sentiment_dissatisfied,
                    size: 80,
                    color: AppColors.secondaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$percentage%',
                    style: AppStyles.mainTextStyle.copyWith(
                      fontSize: 48,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    percentage >= 70
                        ? 'ممتاز!'
                        : percentage >= 50
                            ? 'جيد'
                            : 'يحتاج تحسين',
                    style: AppStyles.subTextStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // تفاصيل النتيجة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  _buildResultItem(
                    'الإجابات الصحيحة',
                    '${_result!.correctAnswers} من ${_result!.totalQuestions}',
                    AppColors.successColor,
                    Icons.check_circle,
                  ),
                  const Divider(height: 32),
                  _buildResultItem(
                    'الإجابات الخاطئة',
                    '${_result!.wrongAnswers} من ${_result!.totalQuestions}',
                    AppColors.errorColor,
                    Icons.cancel,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // زر العودة
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.testColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'العودة للاختبارات',
                  style: AppStyles.subTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(label, style: AppStyles.subHeadingStyle.copyWith(fontSize: 16)),
          ],
        ),
        Text(
          value,
          style: AppStyles.subHeadingStyle.copyWith(
            fontSize: 16,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

