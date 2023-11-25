import 'package:flutter/cupertino.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/constants.dart';

abstract class RestApiHomeScreen {
  static Future<Map<String, dynamic>> homeScreenGetVideo({
    int perPage = perPage,
    String? page,
  }) async {
    Map<String, dynamic> res = {};
    try {
      var response = await APISettings.dio.get(search + key + snippetPart, queryParameters: {
        "maxResults": perPage,
        "pageToken": page,
      });

      if (response.statusCode != STATUS_SUCCESS) return {'server_error': true};
      Map<String, dynamic> json = response.data;
      List<dynamic> listItem = json['items'];
      List<Video> videos = listItem.map((e) => Video.fromJson(e)).toList();
      res['videos'] = videos;
      res['success'] = true;
    } catch (e) {
      res['server_error'] = true;
      debugPrint("home screen get video error is : $e");
    }
    return res;
  }
}
