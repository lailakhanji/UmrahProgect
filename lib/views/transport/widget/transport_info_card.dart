import 'package:flutter/material.dart';

import '../data/transport_model.dart';
import 'info_card.dart';

class TransportCard extends StatelessWidget {
  final TransportModel transports;

  const TransportCard({super.key, required this.transports});

  @override
  Widget build(BuildContext context) {
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
          "تفاصيل النقل",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 20),

        InfoCard(
          title: 'نوع النقل',
          subtitle: transports.type ?? '',
          icon: 'assets/icons/tabler_bus-filled.svg',
        ),
        InfoCard(
          title: 'المطار',
          subtitle: "النقل من   ${transports.departureCity}  الى المطار ",
          icon: 'assets/icons/mdi_flight.svg',
        ),
        InfoCard(
          title: 'بين المدن',
          subtitle: " حافلات بين مكة و المدينة ",
          icon: 'assets/icons/tabler_bus-filled.svg',
        ),
        InfoCard(
          title: 'الزيارات',
          subtitle: " النقل لزيارةالأمكان المقدسة ",
          icon: 'assets/icons/tabler_bus-filled.svg',
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
