import 'package:youtube/utils/constants.dart';

abstract class AbsHomeScreen {
  Future<Map<String, dynamic>> homeScreenGetVideo({
    int perPage = perPage,
    String? page,
    String? videoCategoryId,
    String? searchQuery,
  });
}
