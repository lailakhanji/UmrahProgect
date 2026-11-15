import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';
import 'package:umrahapp/views/transport/data/transport_model.dart';

class TransportApiService {
  Future<Either<String, List<TransportModel>>> getTransport() async {
    try {
      final res = await ApiService.getMethod(
        endPoint: 'Client/ClientTransportServices/GetTransportServices',
        headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
      );

      print(res.statusCode);
      print(res.data);

      final hotels = (res.data as List)
          .map((e) => TransportModel.fromJson(e))
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
