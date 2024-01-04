import 'package:flutter/cupertino.dart';
import 'package:youtube/api/api_env_example.dart';
import 'package:youtube/pages/home_screen/data/repository/abs_home_screen_get_videos.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/youtube_data_api/models/channel.dart' as ytch;
import 'package:youtube/youtube_data_api/models/playlist.dart' as ytp;
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

// here rename
class RestApiHomeScreen implements AbsHomeScreenGetVideos {
  final YoutubeDataApi _youtubeDataApi = YoutubeDataApi.instance;

  @override
  Future<Map<String, dynamic>> homeScreenGetVideo({
    String? q,
    bool clearSearch = false,
  }) async {
    Map<String, dynamic> res = {};
    try {
      // if (videoCategoryId != null) {
      //   params['videoCategoryId'] = videoCategoryId;
      // }
      //
      // var response = await APISettings.dio.get(search + key + snippetPart, queryParameters: params);

      // if (response.statusCode != Constants.STATUS_SUCCESS) return {'server_error': true};
      // Map<String, dynamic> json = response.data;
      // if (json.containsKey('items')) {
      //   List<dynamic> listItem = json['items'];
      //   List<Video> videos = listItem.map((e) => Video.fromJson(e)).toList();

      String query = q ?? ReusableGlobalFunctions.instance.generateRandomString();

      debugPrint("making req: $query");

      var data = await _youtubeDataApi.fetchSearchVideo(
        query,
        YOUTUBE_API_KEY,
        clearLastSearch: clearSearch,
      );

      List<ytv.Video> videos = [];
      List<ytch.Channel> channels = [];
      List<ytp.PlayList> playlist = [];

      for (var each in data) {
        if (each is ytv.Video) {
          videos.add(each);
        } else if (each is ytch.Channel) {
          channels.add(each);
        } else if (each is ytp.PlayList) {
          playlist.add(each);
        }
      }

      res['videos'] = videos;
      res['channels'] = channels;
      res['playlist'] = playlist;
      res['success'] = true;
      // res['next_page_token'] = json['nextPageToken'];
      // res['prev_page_token'] = json['prevPageToken'];
      // }
    } catch (e) {
      res['server_error'] = true;
      debugPrint("home screen get video error is : $e");
    }
    return res;
  }
}
