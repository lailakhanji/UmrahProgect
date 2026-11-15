enum MadinahHotelType { first, second, third }

class MadinahHotelOption {
  final MadinahHotelType type;
  final String title;
  final String description;
  final int stars;
  final double pricePerNight;
  final String imageUrl;

  const MadinahHotelOption({
    required this.type,
    required this.title,
    required this.description,
    required this.stars,
    required this.pricePerNight,
    required this.imageUrl,
  });
}

const List<MadinahHotelOption> madinahHotelOptions = [
  MadinahHotelOption(
    type: MadinahHotelType.first,
    title: 'النسق الأول',
    description: 'يبعد من 20 إلى 100 متر عن الحرم',
    stars: 5,
    pricePerNight: 120,
    imageUrl: 'assets/images/madinah.jpg',
  ),

  MadinahHotelOption(
    type: MadinahHotelType.second,
    title: 'النسق الثاني',
    description: 'يبعد من 100 إلى 200 متر عن الحرم',
    stars: 4,
    pricePerNight: 90,
    imageUrl: 'assets/images/madinah2.jpg',
  ),

  MadinahHotelOption(
    type: MadinahHotelType.third,
    title: 'النسق الثالث',
    description: 'يبعد من 200 إلى 400 متر عن الحرم',
    stars: 3,
    pricePerNight: 60,
    imageUrl: 'assets/images/madinah3.jpg',
  ),
];
