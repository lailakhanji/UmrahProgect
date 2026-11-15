import 'package:flutter/material.dart';

import '../data/trip_model.dart';
import 'info_card.dart';
import 'package:intl/intl.dart';

class TripCard extends StatelessWidget {
  final TripModel package;

  const TripCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    final startDate = DateTime.parse(package.startDate ?? '');
    final endDate = DateTime.parse(package.endDate ?? '');
    return Column(
      children: [
        Container(
          width: 50,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          "تفاصيل الرحلة",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 30),
        InfoCard(
          title: 'الوجهة',
          subtitle: 'مكة_السعودية',
          icon: 'assets/icons/mdi_flight.svg',
        ),
        InfoCard(
          title: 'تاريخ الانطلاق',
          subtitle: DateFormat('yyyy-MM-dd').format(startDate),
          icon: 'assets/icons/mdi_flight.svg',
        ),
        InfoCard(
          title: 'ساعة الانطلاق',
          subtitle: DateFormat('HH:mm').format(startDate),
          icon: 'assets/icons/mdi_flight.svg',
        ),
        InfoCard(
          title: 'تاريخ العودة',
          subtitle: DateFormat('yyyy-MM-dd').format(endDate),
          icon: 'assets/icons/mdi_flight.svg',
        ),
        InfoCard(
          title: 'عدد المقاعد المتبقية بالرحلة',
          subtitle: '${package.maxCapacity}',
          icon: 'assets/icons/mdi_flight.svg',
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            minimumSize: Size(MediaQuery.sizeOf(context).width - 50, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('إغلاق', style: Theme.of(context).textTheme.labelSmall),
        ),
      ],
    );
  }
}
