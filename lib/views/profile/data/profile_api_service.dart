import 'package:umrahapp/views/profile/data/profile_model.dart';

import '../../../services/api_service.dart';
import '../../../services/shared_preferances_service.dart';

class ProfileApiService {
  Future<ProfileModel> getProfile() async {
    final userId = SharedPreferancesService.userId;

    final response = await ApiService.getMethod(
      endPoint: 'Client/ClientUserProfile/GetProfile/$userId',
    );

    return ProfileModel.fromJson(response.data);
  }

  Future<void> updatePassport({
    required String passportNumber,
    required DateTime passportExpiryDate,
  }) async {
    final userId = SharedPreferancesService.userId;

    await ApiService.patchMethod(
      endPoint: 'Client/ClientUserProfile/UpdatePassport/$userId',
      body: {
        'userId': userId,
        'passportNumber': passportNumber,
        'passportExpiryDate': passportExpiryDate.toIso8601String(),
      },
    );
  }
}
