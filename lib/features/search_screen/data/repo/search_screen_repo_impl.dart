import 'package:youtube/features/search_screen/data/source/rest_api_get_suggestion_text.dart';
import 'package:youtube/features/search_screen/domain/repo/search_screen_repo.dart';

class SearchScreenRepoImpl implements SearchScreenRepo {
  final RestApiGetSuggestionText _restApiGetSuggestionText = RestApiGetSuggestionText();

  @override
  Future<Map<String, dynamic>> getSuggestionSearch(String query) =>
      _restApiGetSuggestionText.getSuggestionSearch(query);
}
