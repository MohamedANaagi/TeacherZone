import 'package:flutter/material.dart';

import 'core/router/router.dart';
import 'core/styling/theme_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router (
      debugShowCheckedModeBanner: false,
      title: 'TeacherZone',
      theme: AppThemes.lightTheme,

      routerConfig: RouterGenerator.router ,

    );
  }
}
