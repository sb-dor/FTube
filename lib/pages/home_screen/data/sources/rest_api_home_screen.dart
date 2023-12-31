import 'package:flutter/cupertino.dart';
import 'package:youtube/pages/home_screen/data/repository/abs_home_screen_get_videos.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

// here rename
class RestApiHomeScreen implements AbsHomeScreenGetVideos {
  @override
  Future<Map<String, dynamic>> homeScreenGetVideo({
    int perPage = Constants.perPage,
    String? page,
    String? videoCategoryId,
  }) async {
    Map<String, dynamic> res = {};
    debugPrint("category id : $videoCategoryId");
    try {
      Map<String, dynamic> params = {
        "maxResults": perPage,
        "pageToken": page,
        'type': "video",
        'q': ReusableGlobalFunctions.instance.generateRandomString(length: 3)
      };

      if (videoCategoryId != null) {
        params['videoCategoryId'] = videoCategoryId;
      }

      var response = await APISettings.dio.get(search + key + snippetPart, queryParameters: params);

      if (response.statusCode != Constants.STATUS_SUCCESS) return {'server_error': true};
      Map<String, dynamic> json = response.data;
      if (json.containsKey('items')) {
        List<dynamic> listItem = json['items'];
        List<Video> videos = listItem.map((e) => Video.fromJson(e)).toList();
        res['videos'] = videos;
        res['success'] = true;
        res['next_page_token'] = json['nextPageToken'];
        res['prev_page_token'] = json['prevPageToken'];
      }
    } catch (e) {
      res['server_error'] = true;
      debugPrint("home screen get video error is : $e");
    }
    return res;
  }
}
