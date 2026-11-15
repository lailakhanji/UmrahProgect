import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../data/hotel_model.dart';

class HotelSelectionCard extends StatelessWidget {
  final HotelModel hotel;
  final bool isSelected;
  final VoidCallback onTap;

  const HotelSelectionCard({
    super.key,
    required this.hotel,
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
                  child: hotel.imageUrl.startsWith('http')
                      ? Image.network(
                          hotel.imageUrl,
                          width: 117,
                          height: 81,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _hotelPlaceholder();
                          },
                        )
                      : Image.asset(
                          hotel.imageUrl,
                          width: 117,
                          height: 81,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return _hotelPlaceholder();
                          },
                        ),
                ),

                const SizedBox(width: 8),

                // معلومات الفندق
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text(
                        hotel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // النجوم
                      Row(
                        spacing: 4,
                        children: List.generate(
                          hotel.starsRating,
                          (index) => SvgPicture.asset(
                            'assets/icons/noto_star.svg',
                            width: 16,
                            height: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),


                      Text(
                        'يقع في ${hotel.location}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color.fromRGBO(0, 0, 0, 0.5),
                        ),
                      ),

                      const SizedBox(height: 3),


                      if (hotel.distanceFromHaram > 0)
                        Text(
                          'يبعد مسافة ${hotel.distanceFromHaram} متر عن الحرم',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color.fromRGBO(0, 0, 0, 0.5),
                          ),
                        ),

                      const SizedBox(height: 5),

                      // السعر
                      Row(
                        children: [
                          Spacer(),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${hotel.pricePerNight.toStringAsFixed(0)}\$',
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
                      color: isSelected
                          ? const Color(0xff18A86B)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xff18A86B)
                            : Colors.grey.shade400,
                        width: 1.5,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 14)
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

  Widget _hotelPlaceholder() {
    return Container(
      width: 117,
      height: 81,
      color: Colors.grey.shade200,
      child: const Icon(Icons.hotel, color: Colors.grey, size: 30),
    );
  }
}
