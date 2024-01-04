import 'package:youtube/pages/home_screen/data/sources/rest_api_home_screen.dart';
import 'package:youtube/utils/constants.dart';

abstract class AbsHomeScreenGetVideos {
  Future<Map<String, dynamic>> homeScreenGetVideo({
    String? q,
    bool clearSearch = false,
  });

  factory AbsHomeScreenGetVideos(AbsHomeScreenGetVideos homeScreen) => homeScreen;
}
