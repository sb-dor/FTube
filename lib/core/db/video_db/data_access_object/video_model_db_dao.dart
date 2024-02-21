import 'package:floor/floor.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';

@dao
abstract class VideoModelDbDao {
  @Query("select * from video_history")
  Future<List<VideoModelDb>> getAllVideos();

  @Query("select * from video_history limit :limit")
  Future<List<VideoModelDb>> getLimitVideos(int limit);

  @Query("delete from video_history where id = :id")
  Future<void> deleteVideo(int id);

  @insert
  Future<void> insertVideo(VideoModelDb videoModelDb);
}
