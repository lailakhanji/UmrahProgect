part of 'booking_bloc.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}

// ============================================================
// PACKAGE BOOKING
// ============================================================

class BookingLoading extends BookingState {}

class BookingSuccess extends BookingState {
  final String bookingId;

  BookingSuccess({required this.bookingId});
}

class BookingFailure extends BookingState {
  final String message;

  BookingFailure({required this.message});
}

// ============================================================
// CUSTOM BOOKING
// ============================================================

class CreateBookingLoading extends BookingState {}

class CreateBookingSuccess extends BookingState {
  final String bookingId;

  CreateBookingSuccess({required this.bookingId});
}

class CreateBookingFailure extends BookingState {
  final String message;

  CreateBookingFailure({required this.message});
}

// ============================================================
// FAMILY MEMBER
// ============================================================

class FamilyMemberLoading extends BookingState {}

class FamilyMemberAdded extends BookingState {
  final String bookingId;
  final String? familyMemberId;

  FamilyMemberAdded({required this.bookingId, this.familyMemberId});
}

class FamilyMemberFailure extends BookingState {
  final String message;

  FamilyMemberFailure({required this.message});
}

// ============================================================
// PACKAGE PRICE
// ============================================================

class BookingPriceLoading extends BookingState {}

class BookingPriceSuccess extends BookingState {
  final BookingPriceModel price;

  BookingPriceSuccess(this.price);
}

class BookingPriceFailure extends BookingState {
  final String message;

  BookingPriceFailure(this.message);
}

// ============================================================
// CUSTOM PRICE
// ============================================================

class CustomPriceLoading extends BookingState {}

class CustomPriceSuccess extends BookingState {
  final BookingPriceModel price;

  CustomPriceSuccess(this.price);
}

class CustomPriceFailure extends BookingState {
  final String message;

  CustomPriceFailure(this.message);
}
