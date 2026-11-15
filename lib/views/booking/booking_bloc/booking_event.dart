part of 'booking_bloc.dart';

abstract class BookingEvent {}

class CreatePackageBookingEvent extends BookingEvent {
  final String packageId;

  CreatePackageBookingEvent({required this.packageId});
}

class CalculateCustomPriceEvent extends BookingEvent {
  final String tripId;
  final String hotelId;
  final String transportId;
  final int adults;
  final int children;

  CalculateCustomPriceEvent({
    required this.tripId,
    required this.hotelId,
    required this.transportId,
    required this.adults,
    required this.children,
  });
}

class CreateCustomBookingEvent extends BookingEvent {
  final CreateBookingRequestModel request;

  CreateCustomBookingEvent({required this.request});
}

class AddFamilyMemberEvent extends BookingEvent {
  final String bookingId;
  final FamilyMemberModel member;

  AddFamilyMemberEvent({required this.bookingId, required this.member});
}

class CalculateBookingPriceEvent extends BookingEvent {
  final String packageId;
  final int adults;
  final int children;

  CalculateBookingPriceEvent({
    required this.packageId,
    required this.adults,
    required this.children,
  });
}
