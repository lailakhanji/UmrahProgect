import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';
import 'package:umrahapp/views/cities/data/cities_model.dart';

class CitiesApiService {
  Future<List<CitiesModel>> getCities() async {
    final response = await ApiService.getMethod(
      endPoint: "Client/ClientCities/GetCities",
      headers: {
        "Authorization":
        "Bearer ${SharedPreferancesService.token}",
      },
    );

    print("Cities response: ${response.data}");

    return (response.data as List)
        .map((e) => CitiesModel.fromJson(e))
        .toList();
  }
}