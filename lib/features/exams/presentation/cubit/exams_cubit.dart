import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/di/injection_container.dart';
import 'exams_state.dart';

class ExamsCubit extends Cubit<ExamsState> {
  ExamsCubit() : super(const ExamsState()) {
    loadExams();
  }

  /// تحميل الاختبارات من Firestore
  Future<void> loadExams({String? adminCode, String? studentCode}) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      // جلب الاختبارات من Firestore
      final tests = await InjectionContainer.testRepo.getTests(adminCode: adminCode);

      // جلب نتائج الاختبارات للطالب (إذا كان موجوداً)
      Map<String, int> testScores = {};
      if (studentCode != null && studentCode.isNotEmpty) {
        try {
          final results = await InjectionContainer.testRepo
              .getTestResultsByStudentCode(studentCode);
          for (var result in results) {
            testScores[result.testId] = result.score.round();
          }
        } catch (e) {
          debugPrint('خطأ في جلب نتائج الاختبارات: $e');
          // نستمر حتى لو فشل جلب النتائج
        }
      }

      // تحويل Tests إلى تنسيق exams
      final exams = tests.map((test) {
        final score = testScores[test.id];
        return {
          'id': test.id,
          'title': test.title,
          'description': test.description,
          'questionsCount': test.questionsCount,
          'color': AppColors.examColor.value,
          'isCompleted': score != null,
          'score': score,
          'subject': 'اختبار', // قيمة افتراضية
        };
      }).toList();

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
