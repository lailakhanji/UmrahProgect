import 'dart:io';

import 'package:dio/dio.dart';

import 'shared_preferances_service.dart';

class ApiService {
  static late Dio _dio;

  static const String baseUrl = 'http://umrahbooking.runasp.net';

  static late Uri baseUri;

  static String? token;

  static String prefix = '/api/';

  // =========================================================
  // INIT
  // =========================================================

  static Future<void> init() async {
    baseUri = Uri.parse(baseUrl);
    token = SharedPreferancesService.token;

    // إغلاق الاتصال السابق عند إعادة التهيئة.
    if (_isInitialized) {
      _dio.close(force: true);
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {Headers.acceptHeader: Headers.jsonContentType},
      ),
    );
    _isInitialized = true;
  }

  static bool _isInitialized = false;

  // =========================================================
  // INITIALIZATION CHECK
  // =========================================================

  static void _checkInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ApiService is not initialized. Call ApiService.init() first.',
      );
    }
  }

  // =========================================================
  // URI BUILDER
  // =========================================================

  static Uri _buildUri(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
  }) {
    final normalizedPrefix = prefix.replaceAll(RegExp(r'^/+|/+$'), '');

    final normalizedEndpoint = endPoint.replaceAll(RegExp(r'^/+'), '');

    final path = '/$normalizedPrefix/$normalizedEndpoint';

    return baseUri.replace(path: path, queryParameters: queryParameters);
  }

  // =========================================================
  // REQUEST HEADERS
  // =========================================================

  static Map<String, dynamic> _buildHeaders(
    Map<String, dynamic>? additionalHeaders,
  ) {
    final currentToken = SharedPreferancesService.token;

    final requestHeaders = <String, dynamic>{
      Headers.contentTypeHeader: Headers.jsonContentType,
      Headers.acceptHeader: Headers.jsonContentType,
    };

    if (currentToken != null && currentToken.isNotEmpty) {
      requestHeaders[HttpHeaders.authorizationHeader] = 'Bearer $currentToken';
    }

    if (additionalHeaders != null) {
      requestHeaders.addAll(additionalHeaders);
    }

    return requestHeaders;
  }

  // =========================================================
  // GET
  // =========================================================

  static Future<Response> getMethod({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    _checkInitialized();

    final uri = _buildUri(endPoint, queryParameters: queryParameters);

    return _dio.getUri(
      uri,
      data: body,
      options: Options(headers: _buildHeaders(headers)),
    );
  }

  // =========================================================
  // POST
  // =========================================================

  static Future<Response> postMethod({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    _checkInitialized();

    final uri = _buildUri(endPoint, queryParameters: queryParameters);

    return _dio.postUri(
      uri,
      data: body,
      options: Options(headers: _buildHeaders(headers)),
    );
  }

  // =========================================================
  // PUT
  // =========================================================

  static Future<Response> putMethod({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    _checkInitialized();

    final uri = _buildUri(endPoint, queryParameters: queryParameters);

    return _dio.putUri(
      uri,
      data: body,
      options: Options(headers: _buildHeaders(headers)),
    );
  }

  // =========================================================
  // PATCH
  // =========================================================

  static Future<Response> patchMethod({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, dynamic>? headers,
  }) async {
    _checkInitialized();

    final uri = _buildUri(endPoint, queryParameters: queryParameters);

    return _dio.patchUri(
      uri,
      data: body,
      options: Options(headers: _buildHeaders(headers)),
    );
  }

  // =========================================================
  // DELETE
  // =========================================================

  static Future<Response> deletMethod({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    _checkInitialized();

    final uri = _buildUri(endPoint, queryParameters: queryParameters);

    return _dio.deleteUri(
      uri,
      data: body,
      options: Options(headers: _buildHeaders(null)),
    );
  }
}
