import 'package:youtube/core/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/search_screen/data/source/suggestion_datasoruce.dart';

class SuggestionDatasourceImpl implements SuggestionDatasource {
  final YoutubeDataApi _youtubeDataApi;

  SuggestionDatasourceImpl(this._youtubeDataApi);

  @override
  Future<Map<String, dynamic>> getSuggestionSearch(String query) async {
    final Map<String, dynamic> result = {};
    try {
      final response = await _youtubeDataApi.fetchSuggestions(
        query.trim().isEmpty ? '""' : query.trim(),
      );

      final List<String> data = response.map((e) => e).toList();

      result['data'] = data;
      result['success'] = true;
    } catch (e) {
      result['success'] = true;
      result['data'] = <String>[];
      // debugPrint"getSuggestionSearch error is: $e");
    }
    return result;
  }

  @override
  Future<Map<String, dynamic>> getSearchVideo({
    required String q,
    bool refresh = false,
    String? orderBy,
  }) {
    return RestApiGetVideoData(
      youtubeDataApi: _youtubeDataApi,
    ).getSearchVideo(q: q, refresh: true, orderBy: orderBy);
  }

  @override
  Future<Map<String, dynamic>> getVideoInfo({
    required TypeContent videoContent,
    required String? videoId,
  }) {
    return RestApiGetVideoData(
      youtubeDataApi: _youtubeDataApi,
    ).getVideoInfo(videoContent: TypeContent.snippet, videoId: videoId);
  }
}
