import 'package:youtube/pages/home_screen/data/sources/rest_api_home_screen.dart';
import 'package:youtube/utils/constants.dart';

abstract class AbsHomeScreenGetVideos {
  Future<Map<String, dynamic>> homeScreenGetVideo({
    int perPage = Constants.perPage,
    String? page,
    String? videoCategoryId,
    String? searchQuery,
  });

  factory AbsHomeScreenGetVideos(AbsHomeScreenGetVideos homeScreen) => homeScreen;
}
