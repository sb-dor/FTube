import 'package:flutter/cupertino.dart';
import 'package:youtube/api/api_settings.dart';
import 'package:youtube/api/api_urls.dart';
import 'package:youtube/models/channel_model/channel.dart';
import 'package:youtube/utils/constants.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

abstract class RestApiGetVideoData {
  static final YoutubeDataApi _youtubeDataApi = YoutubeDataApi.instance;

  static Future<Map<String, dynamic>> getVideoInfo({
    required TypeContent videoContent,
    required String? videoId,
  }) async {
    Map<String, dynamic> result = {};

    // String part = _partBuilder(videoContent);

    try {

      var response = await _youtubeDataApi.fetchVideoData(videoId ?? '');

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
      debugPrint("getVideoStatistics error is: $e");
      result['server_error'] = true;
    }
    return result;
  }

  static String _partBuilder(TypeContent videoContent) {
    switch (videoContent) {
      case TypeContent.snippet:
        return snippetPart;
      case TypeContent.contentDetails:
        return contentDetailsPart;
      case TypeContent.statistics:
        return statisticsPart;
      default:
        return contentDetailsPart;
    }
  }
}
