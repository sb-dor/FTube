import 'package:youtube/features/search_screen/domain/repo/search_screen_repo.dart';

class GetSuggestions {
  final SearchScreenRepo _screenRepo;

  GetSuggestions(this._screenRepo);

  Future<Map<String, dynamic>> getSuggestionSearch(String query) =>
      _screenRepo.getSuggestionSearch(query);
}
