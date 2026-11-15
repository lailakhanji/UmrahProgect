class BookingPriceModel {
  final double basePrice;
  final double adultsPrice;
  final double childrenPrice;
  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final double totalPrice;

  BookingPriceModel({
    required this.basePrice,
    required this.adultsPrice,
    required this.childrenPrice,
    required this.subtotal,
    required this.discountPercent,
    required this.discountAmount,
    required this.totalPrice,
  });

  factory BookingPriceModel.fromJson(Map<String, dynamic> json) {
    return BookingPriceModel(
      basePrice: (json['basePrice'] ?? 0).toDouble(),
      adultsPrice: (json['adultsPrice'] ?? 0).toDouble(),
      childrenPrice: (json['childrenPrice'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      discountPercent: (json['discountPercent'] ?? 0).toDouble(),
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
    );
  }
}
