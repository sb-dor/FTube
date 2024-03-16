import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/likes_db/like_model_db/like_model_db.dart';

abstract class LibraryGetLikedVideoDataSource {
  Future<List<BaseVideoModelDb>> getLikedVideos();
}
