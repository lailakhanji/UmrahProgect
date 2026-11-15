import 'package:umrahapp/views/bookings/data/models/transport_details_model.dart';

import 'family_member_details_model.dart';
import 'hotel_details_model.dart';

class BookingDetailsModel {
  final String id;
  final String bookingNumber;

  // ⭐ إضافة tripId
  final String tripId;

  final DateTime bookingDate;
  final String status;
  final double totalAmount;
  final double basePrice;
  final String paymentStatus;
  final String bookingType;

  final String tripTitle;
  final DateTime tripStartDate;
  final DateTime tripEndDate;

  final String? departureCity;
  final String? arrivalCity;

  final HotelDetailsModel? hotel;
  final TransportDetailsModel? transport;

  final List<FamilyMemberDetailsModel> familyMembers;

  BookingDetailsModel({
    required this.id,
    required this.bookingNumber,

    // ⭐
    required this.tripId,

    required this.bookingDate,
    required this.status,
    required this.totalAmount,
    required this.basePrice,
    required this.paymentStatus,
    required this.bookingType,
    required this.tripTitle,
    required this.tripStartDate,
    required this.tripEndDate,
    this.departureCity,
    this.arrivalCity,
    this.hotel,
    this.transport,
    required this.familyMembers,
  });

  factory BookingDetailsModel.fromJson(Map<String, dynamic> json) {
    final transportJson =
    json['transport'] as Map<String, dynamic>?;

    return BookingDetailsModel(
      id: json['id']?.toString() ?? '',

      bookingNumber:
      json['bookingNumber']?.toString() ?? '',

      // ⭐ إضافة tripId من الـ API
      tripId:
      json['tripId']?.toString() ?? '',

      bookingDate:
      DateTime.parse(json['bookingDate']),

      status:
      json['status']?.toString() ?? '',

      totalAmount:
      (json['totalAmount'] as num?)?.toDouble() ?? 0,

      basePrice:
      (json['basePrice'] as num?)?.toDouble() ?? 0,

      paymentStatus:
      json['paymentStatus']?.toString() ?? '',

      bookingType:
      json['bookingType']?.toString() ?? '',

      tripTitle:
      json['tripTitle']?.toString() ?? '',

      tripStartDate:
      DateTime.parse(json['tripStartDate']),

      tripEndDate:
      DateTime.parse(json['tripEndDate']),

      departureCity:
      json['departureCity']?.toString() ??
          transportJson?['departureCity']?.toString(),

      arrivalCity:
      json['arrivalCity']?.toString() ??
          transportJson?['arrivalCity']?.toString(),

      hotel: json['hotel'] != null
          ? HotelDetailsModel.fromJson(
        json['hotel'] as Map<String, dynamic>,
      )
          : null,

      transport: json['transport'] != null
          ? TransportDetailsModel.fromJson(
        json['transport'] as Map<String, dynamic>,
      )
          : null,

      familyMembers:
      (json['familyMembers'] as List? ?? [])
          .map(
            (e) => FamilyMemberDetailsModel.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}