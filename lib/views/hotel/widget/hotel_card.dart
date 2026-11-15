import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:umrahapp/views/hotel/data/hotel_model.dart';

class HotelCard extends StatelessWidget {
  final HotelModel package;

  const HotelCard({super.key, required this.package});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: package.imageUrl.startsWith('http')
                    ? Image.network(
                        package.imageUrl,
                        width: 117,
                        height: 81,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        package.imageUrl,
                        width: 117,
                        height: 81,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        overflow: TextOverflow.ellipsis,

                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),
                    Row(
                      spacing: 4,
                      children: List.generate(
                        package.starsRating,
                        (index) =>
                            SvgPicture.asset('assets/icons/noto_star.svg'),
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'يقع في ${package.location}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ),
                    Text(
                      'يبعد مسافة  ${package.distanceFromHaram} متر عن الحرم',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(0, 0, 0, 0.5),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
