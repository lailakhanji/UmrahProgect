import 'package:flutter/material.dart';

class PackagesCard extends StatelessWidget {
  const PackagesCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Stack(children: []),
    );
  }
}
