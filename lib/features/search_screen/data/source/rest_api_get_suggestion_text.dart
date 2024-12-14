import 'package:flutter/cupertino.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';

class RestApiGetSuggestionText {
  final YoutubeDataApi _youtubeDataApi;

  RestApiGetSuggestionText(this._youtubeDataApi);


  Future<Map<String, dynamic>> getSuggestionSearch(String query) async {
    Map<String, dynamic> result = {};
    try {
      var response = await _youtubeDataApi.fetchSuggestions(
        query.trim().isEmpty ? '""' : query.trim(),
      );

      List<String> data = response.map((e) => e).toList();

      result['data'] = data;
      result['success'] = true;
    } catch (e) {
      result['success'] = true;
      result['data'] = <String>[];
      debugPrint("getSuggestionSearch error is: $e");
    }
    return result;
  }
}
