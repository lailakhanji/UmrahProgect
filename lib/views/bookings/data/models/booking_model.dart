class BookingModel {
  final String id;
  final DateTime bookingDate;
  final String status;
  final double totalAmount;
  final String paymentStatus;
  final String bookingType;
  final int familyMembersCount;

  BookingModel({
    required this.id,
    required this.bookingDate,
    required this.status,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingType,
    required this.familyMembersCount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'].toString(),
      bookingDate: DateTime.parse(json['bookingDate']),
      status: json['status']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      bookingType: json['bookingType']?.toString() ?? '',
      familyMembersCount: json['familyMembersCount'] ?? 0,
    );
  }
}
