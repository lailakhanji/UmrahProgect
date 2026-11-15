import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/booking_api_service.dart';
import '../data/booking_price_api_service.dart';
import '../data/booking_price_model.dart';
import '../data/create_booking_request_model.dart';
import '../data/travel_model.dart';

part 'booking_event.dart';

part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingApiService bookingApiService;
  final BookingPriceApiService bookingPriceApiService;

  BookingBloc(this.bookingApiService, {required this.bookingPriceApiService})
    : super(BookingInitial()) {
    // إنشاء حجز باقة
    on<CreatePackageBookingEvent>(_createPackageBooking);

    // إنشاء حجز Custom
    on<CreateCustomBookingEvent>(_createCustomBooking);

    // إضافة فرد
    on<AddFamilyMemberEvent>(_addFamilyMember);

    // حساب سعر الباقة
    on<CalculateBookingPriceEvent>(_calculateBookingPrice);

    // حساب سعر Custom
    on<CalculateCustomPriceEvent>(_calculateCustomPrice);
  }

  // ============================================================
  // CREATE PACKAGE BOOKING
  // ============================================================

  Future<void> _createPackageBooking(
    CreatePackageBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    try {
      final response = await bookingApiService.createPackageBooking(
        packageId: event.packageId,
      );

      final bookingId = response.data.toString().replaceAll('"', '');

      print('🔥 PACKAGE BOOKING ID: $bookingId');

      if (bookingId.isEmpty) {
        emit(BookingFailure(message: 'لم يتم إرجاع رقم الحجز'));
        return;
      }

      emit(BookingSuccess(bookingId: bookingId));
    } on DioException catch (e) {
      print('❌ PACKAGE BOOKING ERROR');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');

      emit(
        BookingFailure(
          message:
              e.response?.data?.toString() ??
              e.message ??
              'حدث خطأ أثناء إنشاء الحجز',
        ),
      );
    } catch (e) {
      print('❌ CREATE PACKAGE BOOKING ERROR: $e');

      emit(BookingFailure(message: e.toString()));
    }
  }

  // ============================================================
  // CREATE CUSTOM BOOKING
  // ============================================================

  Future<void> _createCustomBooking(
    CreateCustomBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(CreateBookingLoading());

    final result = await bookingApiService.createCustomBooking(
      request: event.request,
    );

    result.fold(
      (error) {
        print('❌ CUSTOM BOOKING ERROR: $error');

        emit(CreateBookingFailure(message: error));
      },
      (bookingId) {
        print('🔥 CUSTOM BOOKING ID: $bookingId');

        emit(CreateBookingSuccess(bookingId: bookingId));
      },
    );
  }

  // ============================================================
  // ADD FAMILY MEMBER
  // ============================================================

  Future<void> _addFamilyMember(
    AddFamilyMemberEvent event,
    Emitter<BookingState> emit,
  ) async {
    print('================================');
    print('🔥 ADD FAMILY MEMBER');
    print('🔥 BOOKING ID: ${event.bookingId}');
    print('🔥 MEMBER: ${event.member.toJson()}');
    print('================================');

    emit(FamilyMemberLoading());

    try {
      final response = await bookingApiService.addFamilyMember(
        bookingId: event.bookingId,
        data: event.member.toJson(),
      );

      print('✅ STATUS: ${response.statusCode}');
      print('✅ RESPONSE: ${response.data}');

      String? familyMemberId;

      if (response.data is Map<String, dynamic>) {
        familyMemberId =
            response.data['id']?.toString() ??
            response.data['familyMemberId']?.toString();
      }

      emit(
        FamilyMemberAdded(
          bookingId: event.bookingId,
          familyMemberId: familyMemberId,
        ),
      );
    } on DioException catch (e) {
      print('❌ ADD FAMILY MEMBER ERROR');
      print('STATUS: ${e.response?.statusCode}');
      print('DATA: ${e.response?.data}');
      print('REQUEST: ${e.requestOptions.data}');

      emit(
        FamilyMemberFailure(
          message:
              e.response?.data?.toString() ??
              e.message ??
              'حدث خطأ أثناء إضافة المسافر',
        ),
      );
    } catch (e) {
      print('❌ ADD FAMILY MEMBER ERROR: $e');

      emit(FamilyMemberFailure(message: e.toString()));
    }
  }

  // ============================================================
  // CALCULATE PACKAGE PRICE
  // ============================================================

  Future<void> _calculateBookingPrice(
    CalculateBookingPriceEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingPriceLoading());

    try {
      final response = await bookingPriceApiService.calculatePrice(
        packageId: event.packageId,

        // المستخدم الأساسي + المسافرين البالغين
        adults: event.adults + 1,

        children: event.children,
      );

      final price = BookingPriceModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      print('🔥 PACKAGE TOTAL: ${price.totalPrice}');

      emit(BookingPriceSuccess(price));
    } catch (e) {
      print('❌ CALCULATE PACKAGE PRICE ERROR: $e');

      emit(BookingPriceFailure(e.toString()));
    }
  }

  // ============================================================
  // CALCULATE CUSTOM PRICE
  // ============================================================
  Future<void> _calculateCustomPrice(
    CalculateCustomPriceEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(CustomPriceLoading());

    try {
      print('====================================');
      print('🔥 CALCULATE CUSTOM PRICE');
      print('🔥 TRIP ID: ${event.tripId}');
      print('🔥 HOTEL ID: ${event.hotelId}');
      print('🔥 TRANSPORT ID: ${event.transportId}');
      print('🔥 ADULTS: ${event.adults + 1}');
      print('🔥 CHILDREN: ${event.children}');
      print('====================================');

      final response = await bookingPriceApiService.calculateCustomPrice(
        tripId: event.tripId,
        hotelId: event.hotelId,
        transportId: event.transportId,
        adults: event.adults + 1,
        children: event.children,
      );

      print('====================================');
      print('✅ CUSTOM PRICE RESPONSE');
      print('STATUS: ${response.statusCode}');
      print('DATA: ${response.data}');
      print('====================================');

      final price = BookingPriceModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      emit(CustomPriceSuccess(price));
    } on DioException catch (e) {
      print('====================================');
      print('❌ CUSTOM PRICE ERROR');
      print('STATUS: ${e.response?.statusCode}');
      print('RESPONSE DATA: ${e.response?.data}');
      print('REQUEST URL: ${e.requestOptions.uri}');
      print('REQUEST DATA: ${e.requestOptions.data}');
      print('REQUEST HEADERS: ${e.requestOptions.headers}');
      print('====================================');

      emit(
        CustomPriceFailure(
          e.response?.data?.toString() ??
              e.message ??
              'حدث خطأ أثناء حساب السعر',
        ),
      );
    } catch (e) {
      print('❌ CUSTOM PRICE ERROR: $e');

      emit(CustomPriceFailure(e.toString()));
    }
  }
}
