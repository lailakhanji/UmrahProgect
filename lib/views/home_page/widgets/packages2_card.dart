import 'package:flutter/material.dart';

import '../data/category_model.dart';

class PackageCard extends StatelessWidget {
  final CategoryModel package;

  const PackageCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(239, 250, 243, 0.5),
        borderRadius: BorderRadius.circular(12),
        border: BoxBorder.all(color: Color.fromRGBO(0, 0, 0, 0.4), width: 0.1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              package.imageUrl ?? '',
              width: 87,
              height: 120,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "شائعة",
                        style: TextStyle(color: Colors.green, fontSize: 10),
                      ),
                    ),
                  ],
                ),

                Text(
                  package.name ?? '',
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,

                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  package.extraServices ?? '',
                  style: const TextStyle(
                    overflow: TextOverflow.ellipsis,
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Text(
                      textDirection: TextDirection.ltr,
                      '${package.totalPrice} \$',
                      style: const TextStyle(
                        color: Color.fromRGBO(13, 155, 92, 1),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    Spacer(),

                    Text(
                      'عرض التفاصيل',
                      style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    ),
                    const Icon(
                      textDirection: TextDirection.ltr,
                      Icons.arrow_back_ios_new,
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),
        ],
      ),
    );
  }
}
