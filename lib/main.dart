import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/router/router.dart';
import 'core/styling/theme_data.dart';
import 'features/user/presentation/cubit/user_cubit.dart';
import 'features/courses/presentation/cubit/courses_cubit.dart';
import 'features/videos/presentation/cubit/videos_cubit.dart';
import 'features/exams/presentation/cubit/exams_cubit.dart';

void main() async {
  debugPrint('🚀 Starting app initialization...');
  
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('✅ WidgetsFlutterBinding initialized');

  try {
    debugPrint('🔥 Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    // في حالة فشل التهيئة، يمكنك إضافة logging هنا
    debugPrint('❌ Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
    // Continue anyway - app might work without Firebase in some cases
  }

  debugPrint('🎨 Running app...');
  runApp(const MyApp());
  debugPrint('✅ App launched successfully');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => UserCubit()),
        BlocProvider(create: (context) => CoursesCubit()),
        BlocProvider(create: (context) => VideosCubit()),
        BlocProvider(create: (context) => ExamsCubit()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'TeacherZone',
        theme: AppThemes.lightTheme,
        routerConfig: RouterGenerator.router,
      ),
    );
  }
}
