import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../widgets/exam_card_widget.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  // بيانات وهمية للاختبارات - نماذج للفيديوهات
  static final List<Map<String, dynamic>> exams = [
    {
      'id': '1',
      'title': 'نموذج - مقدمة في القدرات الكمية',
      'description': 'نموذج اختبار على فيديو مقدمة في القدرات الكمية',
      'questionsCount': 10,
      'videoId': '1',
      'courseId': '1',
      'subject': 'قدرات كمي',
      'color': AppColors.examColor.value,
      'isCompleted': false,
      'score': null,
    },
    {
      'id': '2',
      'title': 'نموذج - الأعداد والعمليات الحسابية',
      'description': 'نموذج اختبار على فيديو الأعداد والعمليات الحسابية',
      'questionsCount': 12,
      'videoId': '2',
      'courseId': '1',
      'subject': 'قدرات كمي',
      'color': AppColors.examColor.value,
      'isCompleted': true,
      'score': 85,
    },
    {
      'id': '3',
      'title': 'نموذج - النسب والتناسب',
      'description': 'نموذج اختبار على فيديو النسب والتناسب',
      'questionsCount': 8,
      'videoId': '4',
      'courseId': '1',
      'subject': 'قدرات كمي',
      'color': AppColors.examColorLight.value,
      'isCompleted': false,
      'score': null,
    },
    {
      'id': '4',
      'title': 'نموذج - الهندسة الأساسية',
      'description': 'نموذج اختبار على فيديو الهندسة الأساسية',
      'questionsCount': 15,
      'videoId': '1',
      'courseId': '2',
      'subject': 'قدرات كمي',
      'color': AppColors.examColorDark.value,
      'isCompleted': false,
      'score': null,
    },
    {
      'id': '5',
      'title': 'نموذج - الزوايا والمثلثات',
      'description': 'نموذج اختبار على فيديو الزوايا والمثلثات',
      'questionsCount': 10,
      'videoId': '3',
      'courseId': '2',
      'subject': 'قدرات كمي',
      'color': AppColors.examColor.value,
      'isCompleted': false,
      'score': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: exams.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: exams.length,
              cacheExtent: 200, // تحسين الأداء للقوائم الطويلة
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: ExamCardWidget(exam: exams[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.quiz_outlined, size: 80, color: AppColors.textLight),
          const SizedBox(height: 16),
          Text(
            'لا توجد اختبارات متاحة حالياً',
            style: AppStyles.textSecondaryStyle.copyWith(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
