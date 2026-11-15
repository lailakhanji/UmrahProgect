import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../services/api_service.dart';
import '../../../services/shared_preferances_service.dart';
import 'create_booking_request_model.dart';

class BookingApiService {
  // ============================================================
  // CREATE CUSTOM BOOKING
  // ============================================================

  Future<Either<String, String>> createCustomBooking({
    required CreateBookingRequestModel request,
  }) async {
    try {
      final response = await ApiService.postMethod(
        endPoint: 'Client/ClientBookings/CreateBookings/Custom',
        body: request.toJson(),
        headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
      );

      print('========================================');
      print('🔥 CREATE CUSTOM BOOKING');
      print('🔥 STATUS: ${response.statusCode}');
      print('🔥 RESPONSE: ${response.data}');
      print('========================================');

      // الـ API يرجع:
      // "ef651898-2719-4dc4-a31d-83ed287e64cf"

      final bookingId = response.data.toString().replaceAll('"', '');

      if (bookingId.isEmpty) {
        return const Left('لم يتم إرجاع رقم الحجز');
      }

      print('🔥 CUSTOM BOOKING ID: $bookingId');

      return Right(bookingId);
    } on DioException catch (e) {
      print('========================================');
      print('❌ CREATE CUSTOM BOOKING ERROR');
      print('❌ STATUS: ${e.response?.statusCode}');
      print('❌ RESPONSE: ${e.response?.data}');
      print('❌ REQUEST: ${e.requestOptions.data}');
      print('========================================');

      return Left(
        e.response?.data?['message']?.toString() ??
            e.message ??
            'حدث خطأ أثناء إنشاء الحجز',
      );
    } catch (e) {
      print('❌ CREATE CUSTOM BOOKING ERROR: $e');

      return Left(e.toString());
    }
  }

  // ============================================================
  // CREATE PACKAGE BOOKING
  // ============================================================

  Future<Response> createPackageBooking({required String packageId}) async {
    print('========================================');
    print('🔥 CREATE PACKAGE BOOKING');
    print('🔥 PACKAGE ID: $packageId');
    print('========================================');

    return await ApiService.postMethod(
      endPoint: 'Client/ClientBookings/CreateBookings/Package',
      body: {'userId': SharedPreferancesService.userId, 'packageId': packageId},
      headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
    );
  }

  // ============================================================
  // ADD FAMILY MEMBER
  // ============================================================

  Future<Response> addFamilyMember({
    required String bookingId,
    required Map<String, dynamic> data,
  }) async {
    print('========================================');
    print('🔥 ADD FAMILY MEMBER');
    print('🔥 BOOKING ID: $bookingId');
    print('🔥 DATA: $data');
    print('========================================');

    return await ApiService.postMethod(
      endPoint: 'Client/ClientBookings/AddFamilyMember/$bookingId/family',
      body: data,
      headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
    );
  }
}
