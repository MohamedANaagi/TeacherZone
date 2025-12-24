import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/landing/presentation/screens/landing_page_screen.dart';
import '../../features/main/presentation/screens/main_screen.dart';
import '../../features/main/presentation/screens/course_videos_screen.dart';
import '../../features/main/presentation/screens/video_player_screen.dart';
import '../../features/main/presentation/screens/exam_quiz_screen.dart';
import '../../features/admin/presentation/screens/admin_main_screen.dart';
import '../../features/admin/presentation/screens/admin_add_code_screen.dart';
import '../../features/admin/presentation/screens/admin_add_course_screen.dart';
import '../../features/admin/presentation/screens/admin_manage_videos_screen.dart';
import '../../features/tests/presentation/screens/admin_add_test_screen.dart';
import 'app_routers.dart';

class RouterGenerator {
  static final GoRouter router = GoRouter(
    initialLocation: kIsWeb ? AppRouters.landingPageScreen : AppRouters.startScreen,
    routes: <GoRoute>[
      GoRoute(
        path: AppRouters.startScreen,
        name: AppRouters.startScreen,
        builder: (context, state) {
          return const StartScreen();
        },
      ),
      GoRoute(
        path: AppRouters.landingPageScreen,
        name: AppRouters.landingPageScreen,
        builder: (context, state) {
          return const LandingPageScreen();
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
        path: '${AppRouters.videoPlayerScreen}/:videoId',
        name: AppRouters.videoPlayerScreen,
        builder: (context, state) {
          final videoData = state.extra as Map<String, dynamic>?;
          if (videoData == null) {
            return MainScreen();
          }
          return VideoPlayerScreen(
            videoUrl: videoData['url'] as String,
            videoTitle: videoData['title'] as String,
            videoDescription: videoData['description'] as String?,
            courseId: videoData['courseId'] as String,
            videoId: state.pathParameters['videoId'] ?? '',
          );
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
      // Admin routes
      GoRoute(
        path: AppRouters.adminMainScreen,
        name: AppRouters.adminMainScreen,
        builder: (context, state) {
          return const AdminMainScreen();
        },
      ),
      GoRoute(
        path: AppRouters.adminAddCodeScreen,
        name: AppRouters.adminAddCodeScreen,
        builder: (context, state) {
          return const AdminAddCodeScreen();
        },
      ),
      GoRoute(
        path: AppRouters.adminAddCourseScreen,
        name: AppRouters.adminAddCourseScreen,
        builder: (context, state) {
          return const AdminAddCourseScreen();
        },
      ),
      GoRoute(
        path: AppRouters.adminManageVideosScreen,
        name: AppRouters.adminManageVideosScreen,
        builder: (context, state) {
          return const AdminManageVideosScreen();
        },
      ),
      GoRoute(
        path: AppRouters.adminAddTestScreen,
        name: AppRouters.adminAddTestScreen,
        builder: (context, state) {
          return const AdminAddTestScreen();
        },
      ),
    ],
  );
}
