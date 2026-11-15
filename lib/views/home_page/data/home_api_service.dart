import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';
import 'package:umrahapp/views/home_page/data/category_model.dart';

class HomeApiService {
  Future<Either<String, List<CategoryModel>>> getCategories() async {
    try {
      final res = await ApiService.getMethod(
        endPoint: 'Client/ClientPackages/GetPackages',
        headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
      );

      print(res.statusCode);
      print(res.data);

      return Right(categoryModelFromJson(json.encode(res.data)));
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
