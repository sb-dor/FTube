import 'package:youtube/core/api/api_env.dart';
import 'package:youtube/core/api/api_urls.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/core/youtube_data_api/models/channel.dart' as ytc;
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';

class RestApiGetVideoData {
  RestApiGetVideoData({required YoutubeDataApi youtubeDataApi}) : _youtubeDataApi = youtubeDataApi;

  final YoutubeDataApi _youtubeDataApi;

  Future<Map<String, dynamic>> getVideoInfo({
    required TypeContent videoContent,
    required String? videoId,
  }) async {
    final Map<String, dynamic> result = {};

    // String part = _partBuilder(videoContent);

    try {
      final response = await _youtubeDataApi.fetchVideoData(videoId ?? '');

      result['success'] = true;
      result['item'] = response;
      // var res = await APISettings.dio.get(
      //   videos + key + part,
      //   queryParameters: {'id': videoId},
      // );
      //
      // if (res.statusCode != Constants.STATUS_SUCCESS) return {"server_error": true};
      //
      // Map<String, dynamic> json = res.data;
      //
      // if (json.containsKey('items')) {
      //   List<dynamic> list = json['items'];
      //
      //   if (list.isNotEmpty) {
      //     result['item'] = list.first;
      //     result['success'] = true;
      //   }
      // }
    } catch (e) {
      // debugPrint"getVideoStatistics error is: $e");
      result['server_error'] = true;
    }
    return result;
  }

  Future<Map<String, dynamic>> getSearchVideo({
    required String q,
    bool refresh = false,
    String? orderBy,
  }) async {
    final Map<String, dynamic> results = {};
    try {
      final List<dynamic> list = await _youtubeDataApi.fetchSearchVideo(
        q,
        YOUTUBE_API_KEY,
        clearLastSearch: refresh,
        orderBy: orderBy,
      );

      // debugPrint"okay: $list");

      final List<ytv.Video> videos = [];
      final List<ytc.Channel> channels = [];

      for (var each in list) {
        if (each is ytv.Video) {
          videos.add(each);
        }
        if (each is ytc.Channel) {
          channels.add(each);
        }
      }

      // // debugPrint"coming also here");

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
    } catch (e) {
      results['server_error'] = true;
      // debugPrint"getSearchVideo error is $e");
    }
    return results;
  }

  static String _partBuilder(TypeContent videoContent) {
    switch (videoContent) {
      case TypeContent.snippet:
        return snippetPart;
      case TypeContent.contentDetails:
        return contentDetailsPart;
      case TypeContent.statistics:
        return statisticsPart;
    }
  }
}
