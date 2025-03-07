import 'package:youtube/features/home_screen/data/sources/home_screen_datasource.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';

class HomeScreenRepoImpl implements HomeScreenRepo {
  final HomeScreenDatasource _restApiHomeScreen;

  HomeScreenRepoImpl(this._restApiHomeScreen);

  @override
  Future<Map<String, dynamic>> getCategories() => _restApiHomeScreen.getCategories();

  @override
  Future<Map<String, dynamic>> homeScreenGetVideo({String? q, bool clearSearch = false}) =>
      _restApiHomeScreen.homeScreenGetVideo(q: q, clearSearch: clearSearch);
}
