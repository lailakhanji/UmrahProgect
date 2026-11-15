import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:umrahapp/views/hotel/widget/hotel_card.dart';

import 'data/hotel_model.dart';
import 'hotel_bloc/hotel_bloc.dart';

class HotelBottomSheet extends StatelessWidget {
  final String hotelName;
  final String packageType;

  const HotelBottomSheet({
    super.key,
    required this.hotelName,
    required this.packageType,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
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

                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/hotel.svg',
                        width: 40,
                        height: 40,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "تفاصيل الإقامة",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'فندق مكة',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 16),

                BlocBuilder<HotelBloc, HotelState>(
                  builder: (context, state) {
                    if (state is LoadingHotelState) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is SuccessHotelState) {
                      final hotel = state.data.firstWhere(
                        (e) => e.name.trim() == hotelName.trim(),
                      );

                      return HotelCard(package: hotel);
                    }

                    if (state is FailedHotelState) {
                      return Text(state.errorMessage);
                    }

                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "فندق المدينة",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 16),

                HotelCard(package: getMadinaHotel(packageType)),

                const SizedBox(height: 50),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    minimumSize: Size(
                      MediaQuery.sizeOf(context).width - 50,
                      48,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'إغلاق',
                    style: Theme.of(context).textTheme.labelSmall,
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

HotelModel getMadinaHotel(String packageType) {
  switch (packageType.trim()) {
    case "مميزة":
      return HotelModel(
        id: "madina-premium",
        name: "فندق نسق الأول",
        description: "إقامة فاخرة ومميزة في المدينة المنورة",
        countryName: "السعودية",
        cityName: "المدينة المنورة",
        location: "النسق الأول",
        imageUrl: "assets/images/manazel_hotel.jpg",
        cityId: "madina",
        distanceFromHaram: 30,
        starsRating: 5,
        pricePerNight: 0,
      );

    case "متوسطة":
      return HotelModel(
        id: "madina-medium",
        name: "فندق نسق الثاني",
        description: "إقامة مريحة في المدينة المنورة",
        countryName: "السعودية",
        cityName: "المدينة المنورة",
        location: "النسق الثاني",
        imageUrl: "assets/images/manazel_hotel.jpg",
        cityId: "madina",
        distanceFromHaram: 100,
        starsRating: 4,
        pricePerNight: 0,
      );

    case "اقتصادية":
      return HotelModel(
        id: "madina-economy",
        name: "فندق نسق الثالث",
        description: "إقامة اقتصادية في المدينة المنورة",
        countryName: "السعودية",
        cityName: "المدينة المنورة",
        location: "النسق الثالث",
        imageUrl: "assets/images/manazel_hotel.jpg",
        cityId: "madina",
        distanceFromHaram: 200,
        starsRating: 3,
        pricePerNight: 0,
      );

    default:
      return HotelModel(
        id: "madina-economy",
        name: "فندق نسق الثالث",
        description: "إقامة اقتصادية في المدينة المنورة",
        countryName: "السعودية",
        cityName: "المدينة المنورة",
        location: "النسق الثالث",
        imageUrl: "assets/images/manazel_hotel.jpg",
        cityId: "madina",
        distanceFromHaram: 200,
        starsRating: 3,
        pricePerNight: 0,
      );
  }
}
