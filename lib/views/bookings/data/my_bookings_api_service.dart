import 'package:dio/dio.dart';

import '../../../services/api_service.dart';
import '../../../services/shared_preferances_service.dart';

class MyBookingsApiService {
  // =========================
  // GET USER BOOKINGS
  // =========================

  Future<Response> getUserBookings() async {
    return await ApiService.getMethod(
      endPoint:
          'Client/ClientBookings/GetUserBooking/${SharedPreferancesService.userId}',
    );
  }

  // =========================
  // GET BOOKING DETAILS
  // =========================

  Future<Response> getBookingDetails({required String bookingId}) async {
    final response = await ApiService.getMethod(
      endPoint: 'Client/ClientBookings/GetBookingDetails/$bookingId/details',
      queryParameters: {'userId': SharedPreferancesService.userId},
    );

    print('================ BOOKING DETAILS ================');
    print(response.data);
    print('=================================================');

    return response;
  }

  // =========================
  // CANCEL BOOKING
  // =========================

  Future<Response> cancelBooking({required String bookingId}) async {
    return await ApiService.putMethod(
      endPoint: 'Client/ClientBookings/CancelBooking/$bookingId/cancel',
      queryParameters: {'userId': SharedPreferancesService.userId},
    );
  }

  // =========================
  // ADD REVIEW
  // =========================

  Future<Response> addReview({
    required String tripId,
    required int rating,
    required String comment,
  }) async {
    final body = {
      'tripId': tripId,
      'userId': SharedPreferancesService.userId,
      'rating': rating,
      'comment': comment,
    };

    print('================ ADD REVIEW ================');
    print('ENDPOINT: Client/ClientReviews/AddReviews');
    print('BODY: $body');

    try {
      final response = await ApiService.postMethod(
        endPoint: 'Client/ClientReviews/AddReviews',
        body: body,
      );

      print('================ REVIEW SUCCESS ================');
      print('STATUS CODE: ${response.statusCode}');
      print('RESPONSE: ${response.data}');
      print('================================================');

      return response;
    } on DioException catch (e) {
      print('================ REVIEW DIO ERROR ================');
      print('STATUS CODE: ${e.response?.statusCode}');
      print('RESPONSE DATA: ${e.response?.data}');
      print('REQUEST DATA: ${e.requestOptions.data}');
      print('REQUEST URL: ${e.requestOptions.uri}');
      print('MESSAGE: ${e.message}');
      print('====================================================');

      rethrow;
    } catch (e) {
      print('================ REVIEW ERROR ================');
      print(e);
      print('==============================================');

      rethrow;
    }
  }
}
