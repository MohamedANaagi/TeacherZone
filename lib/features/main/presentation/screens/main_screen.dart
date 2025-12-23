import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../user/presentation/cubit/user_cubit.dart';
import '../../../user/presentation/cubit/user_state.dart';

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
  bool _hasLoadedUserData = false;

  final List<Widget> _pages = const [
    HomeScreen(),
    CoursesScreen(),
    ExamsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // تحميل بيانات المستخدم عند فتح الشاشة (مهم عند reload في الويب)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserDataIfNeeded();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // إعادة تحميل البيانات عند تغيير dependencies (مثل reload في الويب)
    if (!_hasLoadedUserData) {
      _loadUserDataIfNeeded();
    }
  }

  Future<void> _loadUserDataIfNeeded() async {
    if (!mounted || _hasLoadedUserData) return;
    
    try {
      final userCubit = context.read<UserCubit>();
      final currentState = userCubit.state;
      
      // إذا لم تكن البيانات محملة، قم بتحميلها
      if (currentState.code == null && currentState.adminCode == null) {
        await userCubit.loadUserData();
        _hasLoadedUserData = true;
        debugPrint('✅ تم تحميل بيانات المستخدم في MainScreen');
      } else {
        _hasLoadedUserData = true;
        debugPrint('✅ بيانات المستخدم موجودة بالفعل');
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل بيانات المستخدم: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UserCubit, UserState>(
      listener: (context, userState) {
        // عند تحميل بيانات المستخدم، إعادة تعيين flag للسماح بإعادة التحميل
        final code = userState.code;
        final adminCode = userState.adminCode;
        if (code != null || adminCode != null) {
          if (!_hasLoadedUserData) {
            _hasLoadedUserData = true;
            debugPrint('✅ تم تحميل بيانات المستخدم من UserCubit');
          }
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
