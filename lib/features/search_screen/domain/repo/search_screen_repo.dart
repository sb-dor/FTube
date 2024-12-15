import 'package:youtube/core/utils/enums.dart';

abstract interface class SearchScreenRepo {
  Future<Map<String, dynamic>> getSuggestionSearch(String query);

  Future<Map<String, dynamic>> getVideoInfo({
    required TypeContent videoContent,
    required String? videoId,
  });

  Future<Map<String, dynamic>> getSearchVideo({
    required String q,
    bool refresh = false,
    String? orderBy,
  });
}
