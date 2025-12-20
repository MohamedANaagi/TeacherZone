import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  ExamsCubit() : super(const ExamsState()) {
    loadExams();
  }

  /// تحميل الاختبارات
  Future<void> loadExams() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // TODO: استبدال البيانات الوهمية بجلب البيانات من Firestore
      await Future.delayed(const Duration(milliseconds: 400));

      final exams = _getMockExams();

      emit(
        state.copyWith(
          exams: exams,
          isLoading: false,
        ),
      );
    } catch (e) {
      debugPrint('خطأ في تحميل الاختبارات: $e');
      emit(
        state.copyWith(
          isLoading: false,
          error: 'حدث خطأ أثناء تحميل الاختبارات',
        ),
      );
    }
  }

  /// جلب بيانات وهمية للاختبارات (مؤقتة)
  List<Map<String, dynamic>> _getMockExams() {
    return [
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
  }

  /// تحديث نتيجة الاختبار
  void updateExamResult(String examId, int score) {
    final updatedExams = state.exams.map((exam) {
      if (exam['id'] == examId) {
        return {
          ...exam,
          'isCompleted': true,
          'score': score,
        };
      }
      return exam;
    }).toList();

    emit(state.copyWith(exams: updatedExams));
  }
}
