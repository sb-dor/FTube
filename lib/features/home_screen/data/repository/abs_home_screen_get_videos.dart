abstract class AbsHomeScreenGetVideos {
  Future<Map<String, dynamic>> homeScreenGetVideo({
    String? q,
    bool clearSearch = false,
  });

  factory AbsHomeScreenGetVideos(AbsHomeScreenGetVideos homeScreen) => homeScreen;
}
