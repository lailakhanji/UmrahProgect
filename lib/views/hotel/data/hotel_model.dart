class HotelModel {
  final String id;
  final String name;
  final String description;
  final String countryName;
  final String cityName;
  final String location;
  final String imageUrl;
  final String cityId;
  final int distanceFromHaram;
  final int starsRating;
  final double pricePerNight;

  HotelModel({
    required this.id,
    required this.name,
    required this.description,
    required this.countryName,
    required this.cityName,
    required this.location,
    required this.imageUrl,
    required this.cityId,
    required this.distanceFromHaram,
    required this.starsRating,
    required this.pricePerNight,
  });

  factory HotelModel.fromJson(Map<String, dynamic> json) {
    return HotelModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      countryName: json['countryName']?.toString() ?? '',
      cityName: json['cityName']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      cityId: json['cityId']?.toString() ?? '',
      distanceFromHaram: (json['distanceFromHaram'] as num?)?.toInt() ?? 0,
      starsRating: (json['starsRating'] as num?)?.toInt() ?? 0,
      pricePerNight: (json['pricePerNight'] as num?)?.toDouble() ?? 0,
    );
  }
}
