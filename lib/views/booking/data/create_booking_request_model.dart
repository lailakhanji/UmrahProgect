class CreateBookingRequestModel {
  final String userId;
  final String tripId;
  final String? hotelId;
  final String transportId;

  CreateBookingRequestModel({
    required this.userId,
    required this.tripId,
    this.hotelId,
    required this.transportId,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tripId': tripId,
      if (hotelId != null) 'hotelId': hotelId,
      'transportId': transportId,
    };
  }
}