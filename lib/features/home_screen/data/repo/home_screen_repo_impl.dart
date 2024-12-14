import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/home_screen/data/sources/rest_api_home_screen.dart';
import 'package:youtube/features/home_screen/data/sources/rest_api_home_screen_get_gategories.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';

class HomeScreenRepoImpl implements HomeScreenRepo {
  final RestApiHomeScreen _restApiHomeScreen = RestApiHomeScreen(YoutubeDataApi());
  final RestApiHomeScreenGetCategories _restApiHomeScreenGetCategories =
      RestApiHomeScreenGetCategories();

  @override
  Future<Map<String, dynamic>> getCategories() => _restApiHomeScreenGetCategories.getCategories();

  @override
  Future<Map<String, dynamic>> homeScreenGetVideo({String? q, bool clearSearch = false}) =>
      _restApiHomeScreen.homeScreenGetVideo(
        q: q,
        clearSearch: clearSearch,
      );
}
