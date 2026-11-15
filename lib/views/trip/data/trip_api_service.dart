import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/views/trip/data/trip_model.dart';

class TripApiService {
  Future<Either<String, List<TripModel>>> getTrip() async {
    try {
      final response = await ApiService.getMethod(
        endPoint: 'Client/ClientTrips/GetTrips',
      );

      final data = response.data;

      if (data is! List) {
        return const Left('صيغة البيانات المستلمة من الخادم غير صحيحة.');
      }

      final trips = data.map((item) {
        if (item is! Map) {
          throw const FormatException('Invalid trip data format.');
        }

        return TripModel.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      return Right(trips);
    } on DioException catch (e) {
      return Left(_getErrorMessage(e));
    } on FormatException {
      return const Left('تعذر قراءة بيانات الرحلات المستلمة من الخادم.');
    } catch (e) {
      return const Left('حدث خطأ غير متوقع أثناء تحميل الرحلات.');
    }
  }

  String _getErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.transformTimeout:
        return 'انتهت مهلة معالجة البيانات المستلمة من الخادم.';
      case DioExceptionType.connectionTimeout:
        return 'انتهت مهلة الاتصال بالخادم. حاول مجدداً.';

      case DioExceptionType.sendTimeout:
        return 'انتهت مهلة إرسال الطلب. حاول مجدداً.';

      case DioExceptionType.receiveTimeout:
        return 'استغرق الخادم وقتاً طويلاً للاستجابة.';

      case DioExceptionType.connectionError:
        return 'تعذر الاتصال بالخادم. تحقق من اتصال الإنترنت.';

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        if (statusCode == 401) {
          return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مجدداً.';
        }

        if (statusCode == 403) {
          return 'ليس لديك صلاحية للوصول إلى هذه البيانات.';
        }

        if (statusCode == 404) {
          return 'لم يتم العثور على بيانات الرحلات.';
        }

        if (statusCode != null && statusCode >= 500) {
          return 'يوجد خلل مؤقت في الخادم. حاول لاحقاً.';
        }

        return 'تعذر تحميل الرحلات. رمز الخطأ: $statusCode';

      case DioExceptionType.cancel:
        return 'تم إلغاء طلب تحميل الرحلات.';

      case DioExceptionType.badCertificate:
        return 'تعذر التحقق من شهادة أمان الخادم.';

      case DioExceptionType.unknown:
        return 'حدث خطأ أثناء الاتصال بالخادم.';
    }
  }
}
