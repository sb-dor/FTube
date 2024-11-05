import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';

final class HsGetVideos {
  final HomeScreenRepo _homeScreenRepo;

  HsGetVideos(this._homeScreenRepo);

  Future<Map<String, dynamic>> homeScreenGetVideo({
    String? q,
    bool clearSearch = false,
  }) =>
      _homeScreenRepo.homeScreenGetVideo(q: q, clearSearch: clearSearch);
}
