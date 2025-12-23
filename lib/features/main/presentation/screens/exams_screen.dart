import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../exams/presentation/cubit/exams_cubit.dart';
import '../../../exams/presentation/cubit/exams_state.dart';
import '../widgets/exam_card_widget.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = isWeb && screenWidth > 800;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: BlocBuilder<ExamsCubit, ExamsState>(
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
                    style: AppStyles.textSecondaryStyle.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ExamsCubit>().loadExams();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          if (state.exams.isEmpty) {
            return _buildEmptyState();
          }

          // تصميم متجاوب للويب
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
                itemCount: state.exams.length,
                itemBuilder: (context, index) {
                  return RepaintBoundary(
                    child: ExamCardWidget(exam: state.exams[index]),
                  );
                },
              ),
            );
          } else {
            // List Layout للموبايل
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.exams.length,
              cacheExtent: 200,
              itemBuilder: (context, index) {
                return RepaintBoundary(
                  child: ExamCardWidget(exam: state.exams[index]),
                );
              },
            );
          }
        },
        ),
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
