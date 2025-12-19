import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';

class ExamQuizScreen extends StatefulWidget {
  final Map<String, dynamic> exam;

  const ExamQuizScreen({super.key, required this.exam});

  @override
  State<ExamQuizScreen> createState() => _ExamQuizScreenState();
}

class _ExamQuizScreenState extends State<ExamQuizScreen> {
  int currentQuestionIndex = 0;
  Map<int, int?> selectedAnswers = {}; // questionIndex -> answerIndex
  bool isSubmitted = false;
  int score = 0;

  // أسئلة وهمية - قدرات كمي
  List<Map<String, dynamic>> get questions {
    final examId = widget.exam['id'] as String;

    if (examId == '1') {
      return [
        {
          'question': 'ما هو ناتج: 15 + 27؟',
          'answers': ['40', '42', '44', '46'],
          'correctAnswer': 1,
        },
        {
          'question': 'إذا كان 3x = 21، فما قيمة x؟',
          'answers': ['5', '6', '7', '8'],
          'correctAnswer': 2,
        },
        {
          'question': 'ما هو ناتج: 8 × 7؟',
          'answers': ['54', '56', '58', '60'],
          'correctAnswer': 1,
        },
        {
          'question': 'ما هو 25% من 80؟',
          'answers': ['15', '20', '25', '30'],
          'correctAnswer': 1,
        },
        {
          'question': 'ما هو ناتج: 144 ÷ 12؟',
          'answers': ['10', '11', '12', '13'],
          'correctAnswer': 2,
        },
      ];
    } else if (examId == '2') {
      return [
        {
          'question': 'ما هو ناتج: 45 - 18؟',
          'answers': ['25', '27', '29', '31'],
          'correctAnswer': 1,
        },
        {
          'question': 'إذا كان 2x + 5 = 15، فما قيمة x؟',
          'answers': ['3', '4', '5', '6'],
          'correctAnswer': 2,
        },
        {
          'question': 'ما هو ناتج: 9 × 6؟',
          'answers': ['52', '54', '56', '58'],
          'correctAnswer': 1,
        },
        {
          'question': 'ما هو 30% من 100؟',
          'answers': ['25', '30', '35', '40'],
          'correctAnswer': 1,
        },
      ];
    } else {
      return [
        {
          'question': 'ما هو ناتج: 12 + 18؟',
          'answers': ['28', '30', '32', '34'],
          'correctAnswer': 1,
        },
        {
          'question': 'ما هو ناتج: 7 × 8؟',
          'answers': ['54', '56', '58', '60'],
          'correctAnswer': 1,
        },
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(widget.exam['color'] as int);
    final totalQuestions = questions.length;
    final progress = (currentQuestionIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: color,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
          onPressed: () => _showExitDialog(context, color),
        ),
        title: Text(
          widget.exam['title'] as String,
          style: AppStyles.subTextStyle.copyWith(fontSize: 18),
        ),
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
      body: isSubmitted
          ? RepaintBoundary(child: _buildResultScreen(color))
          : Column(
              children: [
                // معلومات الاختبار
                RepaintBoundary(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.secondaryColor,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.access_time, color: color, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'السؤال ${currentQuestionIndex + 1} من $totalQuestions',
                              style: AppStyles.subHeadingStyle.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(progress * 100).toInt()}%',
                            style: AppStyles.subHeadingStyle.copyWith(
                              fontSize: 14,
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // السؤال
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // نص السؤال
                        RepaintBoundary(
                          child: Container(
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
                            child: Text(
                              questions[currentQuestionIndex]['question']
                                  as String,
                              style: AppStyles.subHeadingStyle.copyWith(
                                fontSize: 18,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // الخيارات
                        ...List.generate(
                          (questions[currentQuestionIndex]['answers'] as List)
                              .length,
                          (index) => RepaintBoundary(
                            child: _buildAnswerOption(
                              index,
                              color,
                              currentQuestionIndex,
                            ),
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
                      if (currentQuestionIndex > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                currentQuestionIndex--;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: color),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'السابق',
                              style: TextStyle(color: color),
                            ),
                          ),
                        ),
                      if (currentQuestionIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (currentQuestionIndex < questions.length - 1) {
                              setState(() {
                                currentQuestionIndex++;
                              });
                            } else {
                              _submitExam(color);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            currentQuestionIndex < questions.length - 1
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

  Widget _buildAnswerOption(int answerIndex, Color color, int questionIndex) {
    final isSelected = selectedAnswers[questionIndex] == answerIndex;
    final answers = questions[questionIndex]['answers'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              selectedAnswers[questionIndex] = answerIndex;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.1)
                  : AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : AppColors.borderColor,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // دائرة الاختيار
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : AppColors.borderColor,
                      width: 2,
                    ),
                    color: isSelected
                        ? color.withOpacity(0.2)
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 16, color: color)
                      : null,
                ),
                const SizedBox(width: 16),
                // نص الإجابة
                Expanded(
                  child: Text(
                    answers[answerIndex] as String,
                    style: AppStyles.textPrimaryStyle.copyWith(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
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

  Widget _buildResultScreen(Color color) {
    final totalQuestions = questions.length;
    final correctAnswers = _calculateScore();
    final percentage = (correctAnswers / totalQuestions * 100).round();

    return SingleChildScrollView(
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
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
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
                  '$correctAnswers من $totalQuestions',
                  AppColors.successColor,
                  Icons.check_circle,
                ),
                const Divider(height: 32),
                _buildResultItem(
                  'الإجابات الخاطئة',
                  '${totalQuestions - correctAnswers} من $totalQuestions',
                  AppColors.errorColor,
                  Icons.cancel,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // أزرار الإجراءات
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
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
            Text(
              label,
              style: AppStyles.subHeadingStyle.copyWith(fontSize: 16),
            ),
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

  int _calculateScore() {
    int correct = 0;
    for (int i = 0; i < questions.length; i++) {
      final selectedAnswer = selectedAnswers[i];
      final correctAnswer = questions[i]['correctAnswer'] as int;
      if (selectedAnswer == correctAnswer) {
        correct++;
      }
    }
    return correct;
  }

  void _submitExam(Color color) {
    final correctAnswers = _calculateScore();
    final totalQuestions = questions.length;
    final percentage = (correctAnswers / totalQuestions * 100).round();

    setState(() {
      isSubmitted = true;
      score = percentage;
    });
  }

  void _showExitDialog(BuildContext context, Color color) {
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
            child: Text('إلغاء', style: TextStyle(color: color)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: color),
            child: const Text(
              'إنهاء',
              style: TextStyle(color: AppColors.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
