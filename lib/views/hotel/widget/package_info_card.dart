import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PackageInfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String icon;

  const PackageInfoCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// السهم
          const Icon(Icons.chevron_left, size: 24),

          const Spacer(),

          /// النص
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
            ],
          ),

          const SizedBox(width: 16),

          /// الأيقونة
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xffF1F8F4),
              shape: BoxShape.circle,
            ),
            child: Center(child: SvgPicture.asset(icon, width: 26, height: 26)),
          ),
        ],
      ),
    );
  }
}
