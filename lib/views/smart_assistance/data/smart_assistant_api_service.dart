import '../../../services/api_service.dart';

class SmartAssistantApiService {
  Future<String> sendMessage(String message) async {
    try {
      final response = await ApiService.postMethod(
        endPoint: 'Client/Chat/Send',
        body: {'message': message},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        if (data is Map<String, dynamic> && data['response'] != null) {
          return data['response'].toString();
        }

        throw Exception('لم يتم العثور على رد المساعد');
      }

      throw Exception('حدث خطأ في الخادم: ${response.statusCode}');
    } on Exception {
      rethrow;
    } catch (e) {
      throw Exception('حدث خطأ أثناء إرسال الرسالة');
    }
  }
}
