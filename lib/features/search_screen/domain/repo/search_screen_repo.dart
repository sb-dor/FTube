abstract interface class SearchScreenRepo {
  Future<Map<String, dynamic>> getSuggestionSearch(String query);
}
