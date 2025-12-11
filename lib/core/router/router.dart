import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/main/presentation/screens/course_videos_screen.dart';
import '../../features/main/presentation/screens/exam_quiz_screen.dart';
import 'app_routers.dart';

class RouterGenerator {
  static final GoRouter router = GoRouter(
    initialLocation: AppRouters.startScreen,
    routes: <GoRoute>[
      GoRoute(
        path: AppRouters.startScreen,
        name: AppRouters.startScreen,
        builder: (context, state) {
          return const StartScreen();
        },
      ),
      GoRoute(
        path: AppRouters.onBoardingScreen,
        name: AppRouters.onBoardingScreen,
        builder: (context, state) {
          return const OnBoardingScreen();
        },
      ),
      GoRoute(
        path: AppRouters.codeInputScreen,
        name: AppRouters.codeInputScreen,
        builder: (context, state) {
          return const CodeInputScreen();
        },
      ),
      GoRoute(
        path: AppRouters.mainScreen,
        name: AppRouters.mainScreen,
        builder: (context, state) {
          return MainScreen();
        },
      ),
      GoRoute(
        path: '${AppRouters.courseVideosScreen}/:courseId',
        name: AppRouters.courseVideosScreen,
        builder: (context, state) {
          final course = state.extra as Map<String, dynamic>?;
          if (course == null) {
            // إذا لم يتم تمرير الكورس، نعيد للصفحة الرئيسية
            return MainScreen();
          }
          return CourseVideosScreen(course: course);
        },
      ),
      GoRoute(
        path: '${AppRouters.examQuizScreen}/:examId',
        name: AppRouters.examQuizScreen,
        builder: (context, state) {
          final exam = state.extra as Map<String, dynamic>?;
          if (exam == null) {
            // إذا لم يتم تمرير الاختبار، نعيد للصفحة الرئيسية
            return MainScreen();
          }
          return ExamQuizScreen(exam: exam);
        },
      ),
    ],
  );
}
