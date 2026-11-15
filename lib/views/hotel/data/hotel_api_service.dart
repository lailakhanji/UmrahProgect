import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';
import 'package:umrahapp/views/home_page/data/category_model.dart';
import 'package:umrahapp/views/hotel/data/hotel_model.dart';

class HotelApiService {
  Future<Either<String, List<HotelModel>>> getHotels() async {
    try {
      final res = await ApiService.getMethod(
        endPoint: 'Client/ClientHotels/GetHotels',
        headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
      );

      print(res.statusCode);
      print(res.data);

      final hotels = (res.data as List)
          .map((e) => HotelModel.fromJson(e))
          .toList();

      return Right(hotels);
    } on DioException catch (e) {
      print("========== DIO ERROR ==========");
      print("Status: ${e.response?.statusCode}");
      print("Body: ${e.response?.data}");
      print("Request Headers: ${e.requestOptions.headers}");

      return Left(e.message ?? "");
    } catch (e, s) {
      print("========== ERROR ==========");
      print(e);
      print(s);

      return Left(e.toString());
    }
  }
}
