import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';

class GuideApiService {
  Future<dynamic> getGuides() async {
    final response = await ApiService.getMethod(
      endPoint: 'Client/ClientRitualContents/GetRitualContents',
      headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
    );

    return response;
  }
}
