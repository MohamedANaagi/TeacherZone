import 'package:flutter/material.dart';
import '../../../core/styling/app_color.dart';

import 'main_widgets/primary_app_bar.dart';

class ExamsScreen extends StatelessWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(child: Text('هنا هتضيف الامتحانات / الكويزات')),
    );
  }
}
