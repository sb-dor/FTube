import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_liked_video_data_source/library_get_liked_video_data_source.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class LibraryGetLikedVideoDataSourceLocally implements LibraryGetLikedVideoDataSource {
  @override
  Future<List<BaseVideoModelDb>> getLikedVideos() async {
    return locator<DbFloor>().likeDao.getAllLikes();
  }
}
