class CalculateCustomPriceRequestModel {
  final String tripId;
  final String hotelId;
  final String transportId;
  final int adults;
  final int children;

  CalculateCustomPriceRequestModel({
    required this.tripId,
    required this.hotelId,
    required this.transportId,
    required this.adults,
    required this.children,
  });

  Map<String, dynamic> toJson() {
    return {
      'tripId': tripId,
      'hotelId': hotelId,
      'transportId': transportId,
      'adults': adults,
      'children': children,
    };
  }
}