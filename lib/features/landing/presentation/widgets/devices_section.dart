import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'section_container.dart';
import 'device_card.dart';

/// قسم الأجهزة المدعومة
class DevicesSection extends StatelessWidget {
  final bool isMobile;

  const DevicesSection({super.key, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      isMobile: isMobile,
      gradientColors: [
        AppColors.backgroundColor,
        AppColors.backgroundLight,
        AppColors.backgroundColor,
      ],
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 48),
          _buildDevicesGrid(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
      ],
    );
  }

  Widget _buildDevicesGrid() {
    final devices = [
      {
        'icon': Icons.phone_iphone,
        'title': 'iPhone',
        'description': 'تطبيق سريع وسهل على iPhone',
        'color': const Color(0xFF1C1C1E), // أسود أنيق
      },
      {
        'icon': Icons.tablet,
        'title': 'iPad',
        'description': 'تجربة ممتازة على iPad',
        'color': const Color(0xFF007AFF), // أزرق iOS
      },
      {
        'icon': Icons.phone_android,
        'title': 'Android',
        'description': 'متوافق مع جميع أجهزة Android',
        'color': const Color(0xFF34C759), // أخضر Android
      },
      {
        'icon': Icons.laptop,
        'title': 'الويب',
        'description': 'يعمل على جميع المتصفحات',
        'color': AppColors.primaryColor,
      },
    ];

    if (isMobile) {
      return Column(
        children: devices.asMap().entries.map((entry) {
          final index = entry.key;
          final device = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < devices.length - 1 ? 20 : 0,
            ),
            child: DeviceCard(
              icon: device['icon'] as IconData,
              title: device['title'] as String,
              description: device['description'] as String,
              color: device['color'] as Color,
            ),
          );
        }).toList(),
      );
    }

    return Row(
      children: devices.asMap().entries.map((entry) {
        final index = entry.key;
        final device = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 16,
              right: index == devices.length - 1 ? 0 : 16,
            ),
            child: DeviceCard(
              icon: device['icon'] as IconData,
              title: device['title'] as String,
              description: device['description'] as String,
              color: device['color'] as Color,
            ),
          ),
        );
      }).toList(),
    );
  }
}
