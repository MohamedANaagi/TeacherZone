import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'core/router/router.dart';
import 'core/styling/theme_data.dart';
import 'core/cubit/user_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e, stackTrace) {
    // في حالة فشل التهيئة، يمكنك إضافة logging هنا
    debugPrint('Firebase initialization error: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserCubit(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'TeacherZone',
        theme: AppThemes.lightTheme,
        routerConfig: RouterGenerator.router,
      ),
    );
  }
}
