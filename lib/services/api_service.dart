import 'dart:io';

import 'package:dio/dio.dart';

class ApiService {
  static late Dio _dio;
  static const String baseUrl="http://umrahbooking.runasp.net";//server Url
static late Uri baseUri;
static String? token;
static String prefix='/api/';
static init() async{
  print(token);
  baseUri=Uri.parse(baseUrl);
  print('host ${baseUri.host}');
  print('scheme ${baseUri.scheme}');
  Map<String,dynamic> headers={
    'Content_Type':'application/json',
    'Accept':'application/json',
  };
  if(token!=null)
    {
      headers.addAll({
        HttpHeaders.authorizationHeader:'Bearer $token'
      });
    }
  BaseOptions options=BaseOptions(headers: headers,
  contentType: 'application/json',
  responseType: ResponseType.json,
  baseUrl: baseUrl);
  _dio=Dio(options);
}
static Future<Response> postMethod({
    required String endPoint,
  Map<String,dynamic>? queryParameters,
  Map<String,dynamic>? body,
})async{
Uri uri=Uri(
host: baseUri.host,
  scheme: baseUri.scheme,
  path: prefix+endPoint,
  queryParameters: queryParameters,
);
return _dio.postUri(uri,data: body);
}
  static Future<Response> putMethod({
    required String endPoint,
    Map<String,dynamic>? queryParameters,
    Map<String,dynamic>? body,
  })async{
    Uri uri=Uri(
      host: baseUri.host,
      scheme: baseUri.scheme,
      path: prefix+endPoint,
      queryParameters: queryParameters,
    );
    return _dio.putUri(uri,data: body);
  }
  static Future<Response> getMethod({
    required String endPoint,
    Map<String,dynamic>? queryParameters,
    Map<String,dynamic>? body,
  })async{
    Uri uri=Uri(
      host: baseUri.host,
      scheme: baseUri.scheme,
      path: prefix+endPoint,
      queryParameters: queryParameters,
    );
    return _dio.getUri(uri);
  }
  static Future<Response> deletMethod({
    required String endPoint,
    Map<String,dynamic>? queryParameters,
    Map<String,dynamic>? body,
  })async{
    Uri uri=Uri(
      host: baseUri.host,
      scheme: baseUri.scheme,
      path: prefix+endPoint,
      queryParameters: queryParameters,
    );
    return _dio.deleteUri(uri);
  }
  static Future<Response> patchMethod({
    required String endPoint,
    Map<String,dynamic>? queryParameters,
    Map<String,dynamic>? body,
  })async{
    Uri uri=Uri(
      host: baseUri.host,
      scheme: baseUri.scheme,
      path: prefix+endPoint,
      queryParameters: queryParameters,
    );
    return _dio.patchUri(uri,data: body);
  }
}