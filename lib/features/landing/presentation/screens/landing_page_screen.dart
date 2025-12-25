import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../widgets/hero_section.dart';
import '../widgets/about_section.dart';
import '../widgets/devices_section.dart';
import '../widgets/how_to_use_section.dart';
import '../widgets/pricing_section.dart';
import '../widgets/contact_section.dart';
import '../widgets/footer_section.dart';

/// صفحة Landing Page للويب
/// تعرض معلومات عن المنصة، الباقات، والتواصل
class LandingPageScreen extends StatelessWidget {
  const LandingPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeroSection(isMobile: isMobile),
            AboutSection(isMobile: isMobile),
            DevicesSection(isMobile: isMobile),
            HowToUseSection(isMobile: isMobile),
            PricingSection(isMobile: isMobile),
            ContactSection(isMobile: isMobile),
            const FooterSection(),
          ],
        ),
      ),
    );
  }
}
