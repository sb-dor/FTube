abstract interface class HomeScreenDatasource {
  Future<Map<String, dynamic>> homeScreenGetVideo({
    String? q,
    bool clearSearch = false,
  });

  Future<Map<String, dynamic>> getCategories();
}