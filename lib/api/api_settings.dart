// ignore_for_file: constant_identifier_names, non_constant_identifier_names
import 'package:dio/dio.dart';
import 'package:youtube/utils/shared_preferences_helper.dart';

abstract class APISettings {
  static const String MAIN_URL = 'https://www.googleapis.com/youtube/v3';

  static late Dio dio;

  static Future<Map<String, String>> headers() async {
    return <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      // 'Authorization': 'Bearer ${SharedPreferencesHelper.instance.getStringByKey(key: 'token')}'
    };
  }

  static Future<void> initDio() async {
    dio = Dio()
      ..options =
          BaseOptions(connectTimeout: const Duration(seconds: 30), headers: await headers());
  }
}
