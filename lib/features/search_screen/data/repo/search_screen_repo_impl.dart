import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/search_screen/data/source/suggestion_datasoruce.dart';
import 'package:youtube/features/search_screen/data/source/suggestion_datasource_impl.dart';
import 'package:youtube/features/search_screen/domain/repo/search_screen_repo.dart';

class SearchScreenRepoImpl implements SearchScreenRepo {
  final SuggestionDatasource _suggestionDatasource;

  SearchScreenRepoImpl(this._suggestionDatasource);

  @override
  Future<Map<String, dynamic>> getSuggestionSearch(String query) =>
      _suggestionDatasource.getSuggestionSearch(query);

  @override
  Future<Map<String, dynamic>> getSearchVideo({
    required String q,
    bool refresh = false,
    String? orderBy,
  }) {
    // TODO: implement getSearchVideo
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getVideoInfo({
    required TypeContent videoContent,
    required String? videoId,
  }) {
    // TODO: implement getVideoInfo
    throw UnimplementedError();
  }
}
