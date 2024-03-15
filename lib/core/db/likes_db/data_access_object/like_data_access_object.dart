import 'package:floor/floor.dart';
import 'package:youtube/core/db/likes_db/like_model_db/like_model_db.dart';

@dao
abstract class LikeDataAccessObject {
  @Query("select * from likes_table")
  Future<List<LikeModelDb>> getAllLikes();

  @insert
  Future<void> insertLikedVideo(LikeModelDb likeModelDb);

  @Query("delete from likes_table where videoId = :videoID")
  Future<void> deleteLikedVideo(String videoID);

  @Query('select * from likes_table where videoId = :videoID')
  Future<LikeModelDb?> getLikedVideo(String videoID);
}
