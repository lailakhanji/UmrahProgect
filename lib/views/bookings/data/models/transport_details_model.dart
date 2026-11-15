class TransportDetailsModel {
  final String type;
  final String departureCity;
  final String arrivalCity;
  final double price;

  TransportDetailsModel({
    required this.type,
    required this.departureCity,
    required this.arrivalCity,
    required this.price,
  });

  factory TransportDetailsModel.fromJson(Map<String, dynamic> json) {
    return TransportDetailsModel(
      type: json['type']?.toString() ?? '',
      departureCity: json['departureCity']?.toString() ?? '',
      arrivalCity: json['arrivalCity']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}
