import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'madinah_hotel_type.dart';

class MadinahHotelSelectionCard extends StatelessWidget {
  final MadinahHotelOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const MadinahHotelSelectionCard({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xffF0FAF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xff18A86B) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    option.imageUrl,
                    width: 117,
                    height: 81,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 8),

                // معلومات الفندق
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        option.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),


                      Row(
                        spacing: 4,
                        children: List.generate(
                          option.stars,
                          (index) => SvgPicture.asset(
                            'assets/icons/noto_star.svg',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),


                      Text(
                        option.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                      ),

                      const SizedBox(height: 5),


                      Row(
                        children: [
                          Spacer(),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${option.pricePerNight.toStringAsFixed(0)}\$',
                                  style: const TextStyle(
                                    color: Color(0xff159461),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / للشخص',
                                  style: TextStyle(
                                    color: Colors.grey.shade500,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),


                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff18A86B)
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                      color: isSelected
                          ? const Color(0xff18A86B)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
