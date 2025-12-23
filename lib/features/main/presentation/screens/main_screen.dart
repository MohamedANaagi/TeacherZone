import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
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
    final isWeb = kIsWeb;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = isWeb && screenWidth > 800;

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
      child: isDesktop
          ? _buildWebLayout(context)
          : _buildMobileLayout(context),
    );
  }

  /// بناء التخطيط للويب (Desktop)
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowColor,
                  blurRadius: 4,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo/Title
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Text(
                    'TeacherZone',
                    style: AppStyles.headingStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Divider(height: 1),
                // Navigation Items
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    children: [
                      _buildNavItem(
                        icon: Icons.home,
                        label: 'الرئيسية',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.menu_book,
                        label: 'الكورسات',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.assignment_turned_in,
                        label: 'الاختبارات',
                        index: 2,
                      ),
                      _buildNavItem(
                        icon: Icons.person,
                        label: 'الملف الشخصي',
                        index: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ClipRect(
                child: _pages[_currentIndex],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// بناء عنصر Navigation للويب
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: AppColors.primaryColor,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                label,
                style: AppStyles.textPrimaryStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.primaryColor
                      : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء التخطيط للموبايل
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.shifting,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
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
