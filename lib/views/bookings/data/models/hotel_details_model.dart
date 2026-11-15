class HotelDetailsModel {
  final String name;
  final int starsRating;
  final int distanceFromHaram;
  final double pricePerNight;
  final String imageUrl;

  HotelDetailsModel({
    required this.name,
    required this.starsRating,
    required this.distanceFromHaram,
    required this.pricePerNight,
    required this.imageUrl,
  });

  factory HotelDetailsModel.fromJson(Map<String, dynamic> json) {
    return HotelDetailsModel(
      name: json['name']?.toString() ?? '',
      starsRating: (json['starsRating'] as num?)?.toInt() ?? 0,
      distanceFromHaram: (json['distanceFromHaram'] as num?)?.toInt() ?? 0,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
      imageUrl: json['imageUrl']?.toString() ?? '',
    );
  }
}
