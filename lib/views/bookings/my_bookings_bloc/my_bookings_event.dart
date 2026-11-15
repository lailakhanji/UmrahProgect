part of 'my_bookings_bloc.dart';

abstract class MyBookingsEvent {}

class GetMyBookingsEvent extends MyBookingsEvent {}

class GetBookingDetailsEvent extends MyBookingsEvent {
  final String bookingId;

  GetBookingDetailsEvent({required this.bookingId});
}

class CancelBookingEvent extends MyBookingsEvent {
  final String bookingId;

  CancelBookingEvent({required this.bookingId});
}

class AddReviewEvent extends MyBookingsEvent {
  final String tripId;
  final int rating;
  final String comment;

  AddReviewEvent({
    required this.tripId,
    required this.rating,
    required this.comment,
  });
}
