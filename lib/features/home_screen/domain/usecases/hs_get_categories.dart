import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';

final class HsGetCategories {
  final HomeScreenRepo _homeScreenRepo;

  HsGetCategories(this._homeScreenRepo);

  Future<Map<String, dynamic>> getCategories() => _homeScreenRepo.getCategories();
}
