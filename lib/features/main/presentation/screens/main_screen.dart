import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';

// Screens
import 'home_screen.dart';
import 'courses_screen.dart';
import 'exams_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    CoursesScreen(),
    ExamsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // إزالة الـ AppBar تماماً لتحسين الشكل
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        // إخفاء النصوص للعناصر غير المحددة لمظهر أنظف
        showUnselectedLabels: false,
        type: BottomNavigationBarType.shifting, // يسمح بتأثيرات أجمل
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            // لون الخلفية عند التفعيل
            backgroundColor: AppColors.secondaryColor,
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.secondaryColor,
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'الكورسات',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.secondaryColor,
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in),
            label: 'الاختبارات',
          ),
          BottomNavigationBarItem(
            backgroundColor: AppColors.secondaryColor,
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'الملف الشخصي',
          ),
        ],
      ),
    );
  }
}
