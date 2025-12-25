import 'package:flutter/material.dart';
import '../../../../../core/styling/app_color.dart';
import '../../../../../core/styling/app_styles.dart';
import 'section_container.dart';
import 'device_card.dart';

/// قسم الأجهزة المدعومة
class DevicesSection extends StatelessWidget {
  final bool isMobile;

  const DevicesSection({
    super.key,
    required this.isMobile,
  });

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
        'color': Colors.black,
      },
      {
        'icon': Icons.tablet,
        'title': 'iPad',
        'description': 'تجربة ممتازة على iPad',
        'color': Colors.blue,
      },
      {
        'icon': Icons.phone_android,
        'title': 'Android',
        'description': 'متوافق مع جميع أجهزة Android',
        'color': Colors.green,
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
        children: devices
            .map((device) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: DeviceCard(
                    icon: device['icon'] as IconData,
                    title: device['title'] as String,
                    description: device['description'] as String,
                    color: device['color'] as Color,
                  ),
                ))
            .toList(),
      );
    }

    return Row(
      children: devices
          .map((device) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: DeviceCard(
                    icon: device['icon'] as IconData,
                    title: device['title'] as String,
                    description: device['description'] as String,
                    color: device['color'] as Color,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

