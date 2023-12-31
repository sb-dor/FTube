import 'package:flutter/cupertino.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/constants.dart';

abstract class RestApiGetVideoSearch {
  static Future<Map<String, dynamic>> getSearchVideo({
    int perPage = Constants.perPage,
    required String? page,
    required String q,
  }) async {
    Map<String, dynamic> results = {};
    try {
      Map<String, dynamic> params = {
        "maxResults": perPage,
        "pageToken": page,
        'type': "video",
        'q': q.trim(),
      };

      debugPrint("query search is: $q");

      var response = await APISettings.dio.get(search + key + snippetPart, queryParameters: params);

      Map<String, dynamic> json = response.data;

      if (json.containsKey('items')) {
        List<dynamic> listItem = json['items'];
        List<Video> videos = listItem.map((e) => Video.fromJson(e)).toList();
        results['videos'] = videos;
        results['success'] = true;
        results['next_page_token'] = json['nextPageToken'];
        results['prev_page_token'] = json['prevPageToken'];
      }

      if (response.statusCode != Constants.STATUS_SUCCESS) return {"server_error": true};
    } catch (e) {
      results['server_error'] = true;
    }
    return results;
  }
}
