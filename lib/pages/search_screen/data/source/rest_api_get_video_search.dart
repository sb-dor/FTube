import 'package:flutter/cupertino.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/youtube_data_api/models/channel.dart' as ytc;
import '../../../../api/api_env.dart';

abstract class RestApiGetVideoSearch {
  static YoutubeDataApi youtubeDataApi = YoutubeDataApi.instance;

  static Future<Map<String, dynamic>> getSearchVideo({
    required String q,
    bool refresh = false,
  }) async {
    Map<String, dynamic> results = {};
    // try {
    List<dynamic>? list = await youtubeDataApi.fetchSearchVideo(
      q,
      YOUTUBE_API_KEY,
      clearLastSearch: refresh,
    );

    debugPrint("okay: $list");

    List<ytv.Video> videos = [];
    List<ytc.Channel> channels = [];

    for (var each in list) {
      if (each is ytv.Video) {
        videos.add(each);
      }
      if (each is ytc.Channel) {
        channels.add(each);
      }
    }

    // debugPrint("coming also here");

    // var response = await APISettings.dio.get(search + key + snippetPart, queryParameters: params);
    //
    // Map<String, dynamic> json = response.data;
    //
    // if (json.containsKey('items')) {
    //   List<dynamic> listItem = json['items'];
    //   List<Video> videos = listItem.map((e) => Video.fromJson(e)).toList();
    results['videos'] = videos;
    results['success'] = true;
    //   results['next_page_token'] = json['nextPageToken'];
    //   results['prev_page_token'] = json['prevPageToken'];
    // }

    //   // if (response.statusCode != Constants.STATUS_SUCCESS) return {"server_error": true};
    // } catch (e) {
    //   results['server_error'] = true;
    //   debugPrint("getSearchVideo error is $e");
    // }
    return results;
  }
}
