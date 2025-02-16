abstract interface class HomeScreenRepo {
  Future<Map<String, dynamic>> getCategories();

  Future<Map<String, dynamic>> homeScreenGetVideo({
    String? q,
    bool clearSearch = false,
  });
}
