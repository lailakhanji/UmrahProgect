import 'package:dartz/dartz.dart';

import '../../../../services/api_service.dart';
import '../../../../services/shared_preferances_service.dart';
import 'notification_model.dart';

class NotificationApiService {
  // =========================================================
  // GET USER NOTIFICATIONS
  // =========================================================

  Future<Either<String, List<NotificationModel>>> getUserNotifications() async {
    try {
      final response = await ApiService.getMethod(
        endPoint:
            'Notifications/GetUserNotifications/${SharedPreferancesService.userId}',
        headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
      );

      final List data = response.data;

      final notifications = data
          .map(
            (json) =>
                NotificationModel.fromJson(Map<String, dynamic>.from(json)),
          )
          .toList();

      return Right(notifications);
    } catch (e) {
      return Left('تعذر تحميل الإشعارات');
    }
  }

  // =========================================================
  // MARK NOTIFICATION AS READ
  // =========================================================

  Future<Either<String, bool>> markAsRead(String notificationId) async {
    try {
      await ApiService.putMethod(
        endPoint: 'Notifications/MarkAsRead/$notificationId',
        headers: {'Authorization': 'Bearer ${SharedPreferancesService.token}'},
      );

      return const Right(true);
    } catch (e) {
      return Left('تعذر تحديث الإشعار');
    }
  }
}
