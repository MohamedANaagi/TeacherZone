import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import '../../../../../core/router/app_routers.dart';

/// صفحة Landing Page للويب
/// تعرض معلومات عن المنصة، الباقات، والتواصل
class LandingPageScreen extends StatefulWidget {
  const LandingPageScreen({super.key});

  @override
  State<LandingPageScreen> createState() => _LandingPageScreenState();
}

class _LandingPageScreenState extends State<LandingPageScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  final Map<String, Animation<double>> _animations = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // إنشاء animations للعناصر المختلفة
    _animations['fade'] = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _animationController.forward();
  }

  void _onScroll() {
    // تفعيل animations عند التمرير
    if (_scrollController.hasClients) {
      final scrollPosition = _scrollController.position.pixels;
      if (scrollPosition > 100 && !_animationController.isAnimating) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Hero Section
            _buildHeroSection(context, isMobile),

            // معلومات عن المنصة
            _buildAboutSection(isMobile),

            // الأجهزة المدعومة
            _buildDevicesSection(isMobile),

            // شرح مفصل عن الاستخدام
            _buildHowToUseSection(isMobile),

            // الباقة
            _buildPricingSection(isMobile),

            // معلومات التواصل
            _buildContactSection(isMobile),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  /// بناء Hero Section
  Widget _buildHeroSection(BuildContext context, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 60 : 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.9),
            AppColors.primaryColor.withOpacity(0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Icon with Animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondaryColor,
                          AppColors.secondaryColor.withOpacity(0.9),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryColor.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school,
                      size: 60,
                      color: AppColors.primaryColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),

            // Title
            Text(
              'TeacherZone',
              style: AppStyles.headingStyle.copyWith(
                fontSize: isMobile ? 32 : 48,
                fontWeight: FontWeight.bold,
                color: AppColors.secondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Subtitle
            Text(
              'منصة إدارة تعليمية متكاملة لإدارة طلابك وكورساتك بسهولة',
              style: AppStyles.textPrimaryStyle.copyWith(
                fontSize: isMobile ? 16 : 20,
                color: AppColors.secondaryColor.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'أنت المسؤول - أنشئ أكواد للطلاب، أضف الكورسات والفيديوهات، ونظم كل شيء',
              style: AppStyles.textPrimaryStyle.copyWith(
                fontSize: isMobile ? 14 : 16,
                color: AppColors.secondaryColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // CTA Button with Gradient
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondaryColor,
                            AppColors.secondaryColor.withOpacity(0.9),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondaryColor.withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.push(AppRouters.codeInputScreen);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 18,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'ابدأ الآن',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(
                              Icons.arrow_forward,
                              size: 24,
                              color: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// بناء قسم الأجهزة المدعومة
  Widget _buildDevicesSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 40 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.backgroundColor,
            AppColors.backgroundLight,
            AppColors.backgroundColor,
          ],
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            Text(
              'متاح على جميع الأجهزة',
              style: AppStyles.headingStyle.copyWith(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'استخدم TeacherZone من أي جهاز في أي وقت',
              style: AppStyles.textSecondaryStyle.copyWith(
                fontSize: isMobile ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            isMobile
                ? Column(
                    children: [
                      _buildDeviceCard(
                        icon: Icons.phone_iphone,
                        title: 'iPhone',
                        description: 'تطبيق سريع وسهل على iPhone',
                        color: Colors.black,
                      ),
                      const SizedBox(height: 24),
                      _buildDeviceCard(
                        icon: Icons.tablet,
                        title: 'iPad',
                        description: 'تجربة ممتازة على iPad',
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 24),
                      _buildDeviceCard(
                        icon: Icons.phone_android,
                        title: 'Android',
                        description: 'متوافق مع جميع أجهزة Android',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 24),
                      _buildDeviceCard(
                        icon: Icons.laptop,
                        title: 'الويب',
                        description: 'يعمل على جميع المتصفحات',
                        color: AppColors.primaryColor,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildDeviceCard(
                          icon: Icons.phone_iphone,
                          title: 'iPhone',
                          description: 'تطبيق سريع وسهل على iPhone',
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildDeviceCard(
                          icon: Icons.tablet,
                          title: 'iPad',
                          description: 'تجربة ممتازة على iPad',
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildDeviceCard(
                          icon: Icons.phone_android,
                          title: 'Android',
                          description: 'متوافق مع جميع أجهزة Android',
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildDeviceCard(
                          icon: Icons.laptop,
                          title: 'الويب',
                          description: 'يعمل على جميع المتصفحات',
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة جهاز
  Widget _buildDeviceCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color, color.withOpacity(0.7)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: AppColors.secondaryColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: AppStyles.subHeadingStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: AppStyles.textSecondaryStyle.copyWith(
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء قسم معلومات عن المنصة
  Widget _buildAboutSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 40 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'لماذا TeacherZone؟',
              style: AppStyles.headingStyle.copyWith(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'منصة شاملة لإدارة مجموعتك التعليمية بكل سهولة واحترافية',
              style: AppStyles.textSecondaryStyle.copyWith(
                fontSize: isMobile ? 14 : 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Features Grid
            isMobile
                ? Column(
                    children: [
                      _buildFeatureCard(
                        icon: Icons.people,
                        title: 'إدارة الطلاب',
                        description:
                            'أنشئ أكواد فريدة لكل طالب وادفع مجموعتك بسهولة',
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureCard(
                        icon: Icons.menu_book,
                        title: 'إدارة الكورسات',
                        description: 'أنشئ كورسات متخصصة ونظمها حسب احتياجاتك',
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureCard(
                        icon: Icons.video_library,
                        title: 'رفع الفيديوهات',
                        description:
                            'ارفع فيديوهات تعليمية عالية الجودة مباشرة إلى المنصة',
                      ),
                      const SizedBox(height: 24),
                      _buildFeatureCard(
                        icon: Icons.quiz,
                        title: 'إنشاء الاختبارات',
                        description: 'صمم اختبارات تفاعلية لتقييم أداء طلابك',
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.people,
                          title: 'إدارة الطلاب',
                          description:
                              'أنشئ أكواد فريدة لكل طالب وادفع مجموعتك بسهولة',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.menu_book,
                          title: 'إدارة الكورسات',
                          description:
                              'أنشئ كورسات متخصصة ونظمها حسب احتياجاتك',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.video_library,
                          title: 'رفع الفيديوهات',
                          description:
                              'ارفع فيديوهات تعليمية عالية الجودة مباشرة إلى المنصة',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildFeatureCard(
                          icon: Icons.quiz,
                          title: 'إنشاء الاختبارات',
                          description: 'صمم اختبارات تفاعلية لتقييم أداء طلابك',
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة ميزة
  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryColor,
                    AppColors.secondaryColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.2),
                          AppColors.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 40, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: AppStyles.subHeadingStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: AppStyles.textSecondaryStyle.copyWith(
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء قسم شرح الاستخدام
  Widget _buildHowToUseSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 40 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundLight,
            AppColors.backgroundColor,
            AppColors.backgroundLight,
          ],
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كيفية الاستخدام',
              style: AppStyles.headingStyle.copyWith(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Steps
            isMobile
                ? Column(
                    children: [
                      _buildStepCard(
                        stepNumber: 1,
                        icon: Icons.admin_panel_settings,
                        title: 'سجل دخول كمسؤول',
                        description:
                            'سجل دخولك باستخدام كود المسؤول الخاص بك للوصول إلى لوحة التحكم',
                        isMobile: true,
                      ),
                      const SizedBox(height: 24),
                      _buildStepCard(
                        stepNumber: 2,
                        icon: Icons.person_add_alt_1,
                        title: 'أنشئ أكواد للطلاب',
                        description:
                            'قم بإنشاء أكواد فريدة لكل طالب في مجموعتك. كل كود مرتبط بك كمسؤول',
                        isMobile: true,
                      ),
                      const SizedBox(height: 24),
                      _buildStepCard(
                        stepNumber: 3,
                        icon: Icons.add_circle_outline,
                        title: 'أضف الكورسات',
                        description:
                            'أنشئ كورسات جديدة مع إضافة العنوان، الوصف، المدرب، والمدة. كل كورس مرتبط بك',
                        isMobile: true,
                      ),
                      const SizedBox(height: 24),
                      _buildStepCard(
                        stepNumber: 4,
                        icon: Icons.video_file,
                        title: 'ارفع الفيديوهات',
                        description:
                            'ارفع فيديوهات تعليمية مباشرة إلى كل كورس. يمكنك إضافة مدة الفيديو وتنظيمها',
                        isMobile: true,
                      ),
                      const SizedBox(height: 24),
                      _buildStepCard(
                        stepNumber: 5,
                        icon: Icons.quiz,
                        title: 'أنشئ الاختبارات',
                        description:
                            'صمم اختبارات تفاعلية مع أسئلة متعددة الخيارات لتقييم أداء طلابك',
                        isMobile: true,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStepCard(
                              stepNumber: 1,
                              icon: Icons.admin_panel_settings,
                              title: 'سجل دخول كمسؤول',
                              description:
                                  'سجل دخولك باستخدام كود المسؤول الخاص بك للوصول إلى لوحة التحكم',
                              isMobile: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStepCard(
                              stepNumber: 2,
                              icon: Icons.person_add_alt_1,
                              title: 'أنشئ أكواد للطلاب',
                              description:
                                  'قم بإنشاء أكواد فريدة لكل طالب في مجموعتك. كل كود مرتبط بك كمسؤول',
                              isMobile: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStepCard(
                              stepNumber: 3,
                              icon: Icons.add_circle_outline,
                              title: 'أضف الكورسات',
                              description:
                                  'أنشئ كورسات جديدة مع إضافة العنوان، الوصف، المدرب، والمدة. كل كورس مرتبط بك',
                              isMobile: false,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStepCard(
                              stepNumber: 4,
                              icon: Icons.video_file,
                              title: 'ارفع الفيديوهات',
                              description:
                                  'ارفع فيديوهات تعليمية مباشرة إلى كل كورس. يمكنك إضافة مدة الفيديو وتنظيمها',
                              isMobile: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: SizedBox(
                          width: 400,
                          child: _buildStepCard(
                            stepNumber: 5,
                            icon: Icons.quiz,
                            title: 'أنشئ الاختبارات',
                            description:
                                'صمم اختبارات تفاعلية مع أسئلة متعددة الخيارات لتقييم أداء طلابك',
                            isMobile: false,
                          ),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة خطوة
  Widget _buildStepCard({
    required int stepNumber,
    required IconData icon,
    required String title,
    required String description,
    required bool isMobile,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + (stepNumber * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: Container(
              padding: EdgeInsets.all(isMobile ? 20 : 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryColor,
                    AppColors.secondaryColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Step Number Badge
                  Container(
                    width: isMobile ? 50 : 60,
                    height: isMobile ? 50 : 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withOpacity(0.8),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: AppStyles.headingStyle.copyWith(
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Icon
                  Container(
                    width: isMobile ? 60 : 80,
                    height: isMobile ? 60 : 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.2),
                          AppColors.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: isMobile ? 30 : 40,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    title,
                    style: AppStyles.subHeadingStyle.copyWith(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Text(
                    description,
                    style: AppStyles.textSecondaryStyle.copyWith(
                      fontSize: isMobile ? 13 : 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء قسم الباقة
  Widget _buildPricingSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 40 : 80,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor.withOpacity(0.08),
            AppColors.primaryColor.withOpacity(0.15),
            AppColors.primaryColor.withOpacity(0.08),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المميزات الشاملة',
              style: AppStyles.headingStyle.copyWith(
                fontSize: isMobile ? 28 : 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'كل ما تحتاجه لإدارة مجموعتك التعليمية في مكان واحد',
              style: AppStyles.textSecondaryStyle.copyWith(
                fontSize: isMobile ? 16 : 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            // Single Pricing Card
            Center(
              child: SizedBox(
                width: isMobile ? double.infinity : 600,
                child: _buildPricingCard(
                  title: 'مميزات TeacherZone للمسؤولين',
                  price: 'منصة متكاملة',
                  features: [
                    'إنشاء أكواد فريدة لكل طالب في مجموعتك',
                    'إدارة كاملة للطلاب مع معلوماتهم وصورهم',
                    'إنشاء كورسات متعددة مع تفاصيل كاملة',
                    'رفع فيديوهات مباشرة إلى المنصة بجودة عالية',
                    'إضافة مدة كل فيديو وتنظيمها بسهولة',
                    'إنشاء اختبارات تفاعلية مع أسئلة متعددة',
                    'تتبع تقدم الطلاب في الكورسات',
                    'تنظيم كامل - كل مسؤول له طلابه وكورساته الخاصة',
                    'لوحة تحكم سهلة الاستخدام',
                    'إمكانية الوصول من أي جهاز (ويب، iOS، Android)',
                  ],
                  isPopular: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة باقة
  Widget _buildPricingCard({
    required String title,
    required String price,
    required List<String> features,
    required bool isPopular,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryColor,
                    AppColors.secondaryColor.withOpacity(0.98),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primaryColor, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 3,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Popular Badge
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.primaryColor.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: AppColors.secondaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'الباقة المميزة',
                            style: AppStyles.textPrimaryStyle.copyWith(
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Center(
                    child: Text(
                      title,
                      style: AppStyles.subHeadingStyle.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Center(
                    child: Text(
                      price,
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),

                  const Divider(thickness: 2),
                  const SizedBox(height: 24),

                  // Features Header
                  Text(
                    'المميزات الشاملة:',
                    style: AppStyles.subHeadingStyle.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Features List
                  ...features.map(
                    (feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.successColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: AppColors.successColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppStyles.textPrimaryStyle.copyWith(
                                fontSize: 16,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء قسم التواصل
  Widget _buildContactSection(bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 40 : 80,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تواصل معنا',
              style: AppStyles.headingStyle.copyWith(
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),

            isMobile
                ? Column(
                    children: [
                      _buildContactCard(
                        icon: Icons.email,
                        title: 'البريد الإلكتروني',
                        content: 'info@teacherzone.com',
                      ),
                      const SizedBox(height: 24),
                      _buildContactCard(
                        icon: Icons.phone,
                        title: 'الهاتف',
                        content: '+20 123 456 7890',
                      ),
                      const SizedBox(height: 24),
                      _buildContactCard(
                        icon: Icons.location_on,
                        title: 'العنوان',
                        content: 'القاهرة، مصر',
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Expanded(
                        child: _buildContactCard(
                          icon: Icons.email,
                          title: 'البريد الإلكتروني',
                          content: 'info@teacherzone.com',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildContactCard(
                          icon: Icons.phone,
                          title: 'الهاتف',
                          content: '+20 123 456 7890',
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _buildContactCard(
                          icon: Icons.location_on,
                          title: 'العنوان',
                          content: 'القاهرة، مصر',
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }

  /// بناء بطاقة تواصل
  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.9 + (0.1 * value),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondaryColor,
                    AppColors.secondaryColor.withOpacity(0.95),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primaryColor.withOpacity(0.2),
                          AppColors.primaryColor.withOpacity(0.1),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 30, color: AppColors.primaryColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    style: AppStyles.subHeadingStyle.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: AppStyles.textSecondaryStyle.copyWith(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// بناء Footer
  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.9),
            AppColors.primaryColor.withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * value),
                    child: Text(
                      'TeacherZone',
                      style: AppStyles.headingStyle.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              '© 2024 TeacherZone. جميع الحقوق محفوظة.',
              style: AppStyles.textPrimaryStyle.copyWith(
                color: AppColors.secondaryColor.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
