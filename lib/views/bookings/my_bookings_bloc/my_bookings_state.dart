part of 'my_bookings_bloc.dart';

abstract class MyBookingsState {}

class MyBookingsInitial extends MyBookingsState {}

class MyBookingsLoading extends MyBookingsState {}

class MyBookingsLoaded extends MyBookingsState {
  final List<BookingModel> bookings;

  MyBookingsLoaded({required this.bookings});
}

class BookingDetailsLoaded extends MyBookingsState {
  final BookingDetailsModel booking;

  BookingDetailsLoaded({required this.booking});
}

class BookingDetailsLoading extends MyBookingsState {}

class BookingCancelled extends MyBookingsState {}

class MyBookingsError extends MyBookingsState {
  final String message;

  MyBookingsError({required this.message});
}

class ReviewAdded extends MyBookingsState {}
