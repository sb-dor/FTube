import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

abstract class PlaylistVideosInnerScreenDataSource {
  Future<List<BaseVideoModelDb>> getPlaylistsVideos({
    int page = 1,
    int currentListLength = 0,
    PlaylistModelDb? playlistModelDb,
  });

  Future<List<BaseVideoModelDb>> getLikedVideos({int page = 1, int currentListLength = 0});
}
