// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:dio/dio.dart';
import 'api_urls.dart';

abstract class APISettings {
  static late Dio dio;

  static Future<Map<String, String>> headers() async {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      // 'Authorization': "Bearer $YOUTUBE_API_KEY"
    };
  }

  static Future<void> initDio() async {
    dio =
        Dio()
          ..options = BaseOptions(
            baseUrl: MAIN_URL,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: await headers(),
          );
  }
}
