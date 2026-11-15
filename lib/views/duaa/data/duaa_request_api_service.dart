import '../../../services/api_service.dart';
import 'models/duaa_request_model.dart';

class DuaaRequestApi {
  static Future<List<DuaaRequestModel>> getDuaaRequests(String userId) async {
    final response = await ApiService.getMethod(
      endPoint: 'Client/ClientDuaaRequests/GetDuaaRequests/$userId',
    );

    final List data = response.data;

    return data.map((json) => DuaaRequestModel.fromJson(json)).toList();
  }

  static Future<void> createDuaaRequest(DuaaRequestModel request) async {
    await ApiService.postMethod(
      endPoint: 'Client/ClientDuaaRequests/CreateDuaaRequest',
      body: request.toJson(),
    );
  }

  static Future<void> markAsCompleted(String id) async {
    await ApiService.patchMethod(
      endPoint: 'Client/ClientDuaaRequests/MarkAsCompleted/$id',
    );
  }
}
