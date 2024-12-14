import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_liked_video_data_source/library_get_liked_video_data_source.dart';

class LibraryGetLikedVideoDataSourceLocally implements LibraryGetLikedVideoDataSource {
  final DbFloor _dbFloor;

  LibraryGetLikedVideoDataSourceLocally(this._dbFloor);

  @override
  Future<List<BaseVideoModelDb>> getLikedVideos() async {
    return _dbFloor.likeDao.getAllLikes();
  }
}
