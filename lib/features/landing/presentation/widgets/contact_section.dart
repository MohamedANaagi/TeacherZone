import 'package:flutter/material.dart';
import '../../../../../core/styling/app_styles.dart';
import 'section_container.dart';
import 'contact_card.dart';

/// قسم التواصل
class ContactSection extends StatelessWidget {
  final bool isMobile;

  const ContactSection({
    super.key,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      isMobile: isMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 48),
          _buildContactCards(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'تواصل معنا',
      style: AppStyles.headingStyle.copyWith(
        fontSize: 36,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildContactCards() {
    final contacts = [
      {
        'icon': Icons.email,
        'title': 'البريد الإلكتروني',
        'content': 'info@teacherzone.com',
      },
      {
        'icon': Icons.phone,
        'title': 'الهاتف',
        'content': '+20 123 456 7890',
      },
      {
        'icon': Icons.location_on,
        'title': 'العنوان',
        'content': 'القاهرة، مصر',
      },
    ];

    if (isMobile) {
      return Column(
        children: contacts
            .map((contact) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: ContactCard(
                    icon: contact['icon'] as IconData,
                    title: contact['title'] as String,
                    content: contact['content'] as String,
                  ),
                ))
            .toList(),
      );
    }

    return Row(
      children: contacts
          .map((contact) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: ContactCard(
                    icon: contact['icon'] as IconData,
                    title: contact['title'] as String,
                    content: contact['content'] as String,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

