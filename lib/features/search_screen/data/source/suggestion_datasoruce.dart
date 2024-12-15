abstract interface class SuggestionDatasource {
  Future<Map<String, dynamic>> getSuggestionSearch(String query);
}
