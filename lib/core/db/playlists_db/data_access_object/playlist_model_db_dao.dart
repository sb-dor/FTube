import 'package:floor/floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_videos_model_db/playlist_videos_model_db.dart';

@dao
abstract class PlaylistModelDao {
  @Query('select * from playlists limit :limit')
  Future<List<PlaylistModelDb>> getPlaylists(int limit);

  @Query('select * from playlists')
  Future<List<PlaylistModelDb>> getAllPlaylists();

  @Query("select * from playlist_videos where play_list_id = :id limit :limit")
  Future<List<PlaylistVideosModelDb>> getPlaylistVideos(int id, int limit);

  @Query("select * from playlist_videos where play_list_id = :id")
  Future<List<PlaylistVideosModelDb>> getPlaylistAllVideos(int id);

  @Query("select * from playlist_videos where videoId = :videoId")
  Future<PlaylistVideosModelDb?> getVideoFromPlaylistVideos(String videoId);

  @Query("select * from playlists where id = :playlistId")
  Future<PlaylistModelDb?> getVideoPlaylist(int playlistId);

  @Query('delete from playlists where id :id')
  Future<void> deletePlaylist(int id);

  @Query('delete from playlist_videos where videoId = :videoId')
  Future<void> deleteVideoFromAllPlaylists(String videoId);

  @insert
  Future<void> createPlaylist(PlaylistModelDb playlistModelDb);

  @Insert(onConflict: OnConflictStrategy.ignore)
  Future<void> insertVideoIntoPlaylist(
    PlaylistVideosModelDb playlistVideosModelDb,
  );

  // here deletion for playlist videos if after deleting playlist videos will not be deleted
}
