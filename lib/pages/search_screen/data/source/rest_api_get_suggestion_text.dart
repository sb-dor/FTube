import 'package:flutter/cupertino.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

abstract class RestApiGetSuggestionText {
  static final YoutubeDataApi _youtubeDataApi = YoutubeDataApi.instance;

  static Future<Map<String, dynamic>> getSuggestionSearch(String query) async {
    Map<String, dynamic> result = {};
    try {
      var response = await _youtubeDataApi.fetchSuggestions(query.trim().isEmpty ? '""' : query.trim());

      List<String> data = response.map((e) => e).toList();

      result['data'] = data;
      result['success'] = true;
    } catch (e) {
      result['server_error'] = true;
      debugPrint("getSuggestionSearch error is: $e");
    }
    return result;
  }
}
