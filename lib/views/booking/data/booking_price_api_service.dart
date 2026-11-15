import 'package:dio/dio.dart';

import '../../../services/api_service.dart';
import '../../../services/shared_preferances_service.dart';

class BookingPriceApiService {
  // ============================================================
  // CALCULATE PACKAGE PRICE
  // ============================================================

  Future<Response> calculatePrice({
    required String packageId,
    required int adults,
    required int children,
  }) async {
    return await ApiService.postMethod(
      endPoint: 'Client/ClientBookings/CalculatePrice/calculate',
      body: {'packageId': packageId, 'adults': adults, 'children': children},
      headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
    );
  }

  // ============================================================
  // CALCULATE CUSTOM PRICE
  // ============================================================

  Future<Response> calculateCustomPrice({
    required String tripId,
    required String hotelId,
    required String transportId,
    required int adults,
    required int children,
  }) async {
    return await ApiService.postMethod(
      endPoint: 'Client/ClientBookings/CalculateCustomPrice/calculate/custom',
      body: {
        'tripId': tripId,
        'hotelId': hotelId,
        'transportId': transportId,
        'adults': adults,
        'children': children,
      },
      headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
    );
  }
}
