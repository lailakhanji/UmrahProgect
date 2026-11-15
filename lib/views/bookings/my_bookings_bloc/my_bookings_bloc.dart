import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/my_bookings_api_service.dart';
import '../data/models/booking_details_model.dart';
import '../data/models/booking_model.dart';

part 'my_bookings_event.dart';

part 'my_bookings_state.dart';

class MyBookingsBloc extends Bloc<MyBookingsEvent, MyBookingsState> {
  final MyBookingsApiService apiService;

  MyBookingsBloc(this.apiService) : super(MyBookingsInitial()) {
    on<GetMyBookingsEvent>(_getMyBookings);
    on<GetBookingDetailsEvent>(_getBookingDetails);
    on<CancelBookingEvent>(_cancelBooking);
    on<AddReviewEvent>(_addReview);
  }

  Future<void> _addReview(
    AddReviewEvent event,
    Emitter<MyBookingsState> emit,
  ) async {
    try {
      await apiService.addReview(
        tripId: event.tripId,
        rating: event.rating,
        comment: event.comment,
      );

      emit(ReviewAdded());
    } catch (e) {
      emit(MyBookingsError(message: e.toString()));
    }
  }

  Future<void> _getMyBookings(
    GetMyBookingsEvent event,
    Emitter<MyBookingsState> emit,
  ) async {
    emit(MyBookingsLoading());
    try {
      final response = await apiService.getUserBookings();
      final List data = response.data;
      final bookings = data.map((json) => BookingModel.fromJson(json)).toList();
      emit(MyBookingsLoaded(bookings: bookings));
    } catch (e) {
      emit(MyBookingsError(message: e.toString()));
    }
  }

  Future<void> _getBookingDetails(
    GetBookingDetailsEvent event,
    Emitter<MyBookingsState> emit,
  ) async {
    emit(BookingDetailsLoading());
    try {
      final response = await apiService.getBookingDetails(
        bookingId: event.bookingId,
      );
      final booking = BookingDetailsModel.fromJson(response.data);
      emit(BookingDetailsLoaded(booking: booking));
    } catch (e) {
      emit(MyBookingsError(message: e.toString()));
    }
  }

  Future<void> _cancelBooking(
    CancelBookingEvent event,
    Emitter<MyBookingsState> emit,
  ) async {
    try {
      await apiService.cancelBooking(bookingId: event.bookingId);

      emit(BookingCancelled());
    } catch (e) {
      emit(MyBookingsError(message: e.toString()));
    }
  }
}
