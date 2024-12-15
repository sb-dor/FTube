import 'package:flutter/cupertino.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/search_screen/data/source/suggestion_datasoruce.dart';

class SuggestionDatasourceImpl implements SuggestionDatasource {
  final YoutubeDataApi _youtubeDataApi;

  SuggestionDatasourceImpl(this._youtubeDataApi);


  @override
  Future<Map<String, dynamic>> getSuggestionSearch(String query) async {
    Map<String, dynamic> result = {};
    try {
      var response = await _youtubeDataApi.fetchSuggestions(
        query
            .trim()
            .isEmpty ? '""' : query.trim(),
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
