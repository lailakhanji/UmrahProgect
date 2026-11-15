import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:umrahapp/services/api_service.dart';
import 'package:umrahapp/services/shared_preferances_service.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_onLoginEvent);
    on<RegisterEvent>(_onRegisterEvent);
    on<ClearAuthErrorEvent>(_onClearAuthErrorEvent);
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<void> _onLoginEvent(LoginEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      final response = await ApiService.postMethod(
        endPoint: 'Auth/login',
        body: {'email': event.email.trim(), 'password': event.password},
      );

      final data = response.data;


      SharedPreferancesService.token = data['token'];
      ApiService.token = data['token'];


      SharedPreferancesService.userId = data['id'];


      SharedPreferancesService.name = '${data['firstName'] ?? ''}'.trim();

      emit(AuthSuccess());
    } on DioException catch (e) {
      debugPrint('LOGIN ERROR');
      debugPrint('STATUS CODE: ${e.response?.statusCode}');
      debugPrint('DATA: ${e.response?.data}');
      debugPrint('TYPE: ${e.type}');

      emit(AuthFailed(message: _getLoginErrorMessage(e)));
    } catch (e, stackTrace) {
      debugPrint('LOGIN UNKNOWN ERROR: $e');
      debugPrint(stackTrace.toString());

      emit(AuthFailed(message: 'حدث خطأ غير متوقع، حاول مرة أخرى'));
    }
  }

  // =========================================================
  // REGISTER
  // =========================================================

  Future<void> _onRegisterEvent(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      debugPrint('REGISTER START');

      final response = await ApiService.postMethod(
        endPoint: 'Auth/register',
        body: {
          'email': event.email.trim(),
          'password': event.password,
          'confirmPassword': event.confirmPassword,
          'firstName': event.firstName.trim(),
          'lastName': event.lastName.trim(),
          'phone': event.phone.trim(),
          'passportNumber': event.passportNumber.trim(),
          'passportExpiryDate': event.passportExpiryDate,
          'dateOfBirth': event.dateOfBirth,


        },
      );

      debugPrint('REGISTER SUCCESS');
      debugPrint(response.data.toString());

      final data = response.data;

      if (data is Map<String, dynamic>) {
        if (data['token'] != null) {
          SharedPreferancesService.token = data['token'];
          ApiService.token = data['token'];
        }

        if (data['id'] != null) {
          SharedPreferancesService.userId = data['id'];
        }

        if (data['firstName'] != null) {
          SharedPreferancesService.name = '${data['firstName']}'.trim();
        }
      }

      emit(AuthSuccess());
    } on DioException catch (e) {
      debugPrint('REGISTER ERROR');
      debugPrint('STATUS CODE: ${e.response?.statusCode}');
      debugPrint('DATA: ${e.response?.data}');
      debugPrint('TYPE: ${e.type}');

      emit(AuthFailed(message: _getRegisterErrorMessage(e)));
    } catch (e, stackTrace) {
      debugPrint('REGISTER UNKNOWN ERROR: $e');
      debugPrint(stackTrace.toString());

      emit(AuthFailed(message: 'حدث خطأ غير متوقع، حاول مرة أخرى'));
    }
  }

  // =========================================================
  // LOGIN ERROR HANDLER
  // =========================================================

  String _getLoginErrorMessage(DioException e) {
    // ---------------------------------------------
    // لا يوجد إنترنت
    // ---------------------------------------------

    if (_isNetworkError(e)) {
      return 'تأكد من اتصالك بالإنترنت';
    }

    final statusCode = e.response?.statusCode;

    // ---------------------------------------------
    // بيانات الدخول خاطئة
    // ---------------------------------------------

    if (statusCode == 400 || statusCode == 401) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحين';
    }

    // ---------------------------------------------
    // Server Error
    // ---------------------------------------------

    if (statusCode != null && statusCode >= 500) {
      return 'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً';
    }

    // ---------------------------------------------
    // محاولة قراءة رسالة الـ API
    // ---------------------------------------------

    final apiMessage = _extractApiMessage(e.response?.data);

    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }

    return 'حدث خطأ أثناء تسجيل الدخول، حاول مرة أخرى';
  }

  // =========================================================
  // REGISTER ERROR HANDLER
  // =========================================================

  String _getRegisterErrorMessage(DioException e) {
    // ---------------------------------------------
    // لا يوجد إنترنت
    // ---------------------------------------------

    if (_isNetworkError(e)) {
      return 'تأكد من اتصالك بالإنترنت';
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // ---------------------------------------------
    // الحساب موجود مسبقاً
    // ---------------------------------------------

    if (statusCode == 409) {
      return 'هذا الحساب موجود مسبقاً';
    }

    // ---------------------------------------------
    // بعض الـ APIs ترجع 400 للحساب الموجود
    // ---------------------------------------------

    final apiMessage = _extractApiMessage(data);

    if (apiMessage != null) {
      final lower = apiMessage.toLowerCase();

      if (lower.contains('already exists') ||
          lower.contains('already registered') ||
          lower.contains('exist') ||
          apiMessage.contains('موجود') ||
          apiMessage.contains('مسجل')) {
        return 'هذا الحساب موجود مسبقاً';
      }
    }

    // ---------------------------------------------
    // Validation من السيرفر
    // ---------------------------------------------

    if (statusCode == 400) {
      return apiMessage ??
          'البيانات المدخلة غير صحيحة، يرجى التأكد من المعلومات';
    }

    // ---------------------------------------------
    // Server Error
    // ---------------------------------------------

    if (statusCode != null && statusCode >= 500) {
      return 'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً';
    }

    return apiMessage ?? 'حدث خطأ أثناء إنشاء الحساب، حاول مرة أخرى';
  }

  // =========================================================
  // NETWORK ERROR
  // =========================================================

  bool _isNetworkError(DioException e) {
    return e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout;
  }

  // =========================================================
  // API MESSAGE
  // =========================================================

  String? _extractApiMessage(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is String) {
      return data;
    }

    if (data is Map) {
      final possibleKeys = ['message', 'title', 'detail', 'error', 'errors'];

      for (final key in possibleKeys) {
        final value = data[key];

        if (value == null) {
          continue;
        }

        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }

        if (value is Map) {
          final messages = <String>[];

          for (final entry in value.entries) {
            final item = entry.value;

            if (item is List) {
              messages.addAll(item.map((e) => e.toString()));
            } else {
              messages.add(item.toString());
            }
          }

          if (messages.isNotEmpty) {
            return messages.join('\n');
          }
        }

        if (value is List && value.isNotEmpty) {
          return value.join('\n');
        }
      }
    }

    return null;
  }

  // =========================================================
  // CLEAR ERROR
  // =========================================================

  FutureOr<void> _onClearAuthErrorEvent(
    ClearAuthErrorEvent event,
    Emitter<AuthState> emit,
  ) {
    emit(AuthInitial());
  }
}
