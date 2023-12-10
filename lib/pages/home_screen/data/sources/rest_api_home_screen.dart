import 'package:flutter/cupertino.dart';
import 'package:youtube/pages/home_screen/data/repository/abs_home_screen.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

class RestApiHomeScreen implements AbsHomeScreen {
  static RestApiHomeScreen? _instance;

  static RestApiHomeScreen get instance => _instance ??= RestApiHomeScreen._();

  RestApiHomeScreen._();

  @override
  Future<Map<String, dynamic>> homeScreenGetVideo({
    int perPage = perPage,
    String? page,
    String? videoCategoryId,
    String? searchQuery,
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

      if (response.statusCode != STATUS_SUCCESS) return {'server_error': true};
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

  Future<Map<String, dynamic>> getCategories() async {
    Map<String, dynamic> res = {};
    try {
      final response =
          await APISettings.dio.get(videoCategories + key + snippetPart + regionCode + language);

      if (response.statusCode != STATUS_SUCCESS) return {'server_error': true};

      Map<String, dynamic> json = response.data;

      List<dynamic> listCat = json['items'];

      List<VideoCategory> categories = listCat.map((e) => VideoCategory.fromJson(e)).toList();

      res['categories'] = categories;
      res['success'] = true;
    } catch (e) {
      debugPrint("getCategories error is $e");
      res['server_error'] = true;
    }
    return res;
  }
}
