import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

abstract class PlaylistInnerScreenRepository {
  Future<List<PlaylistModelDb>> getPlaylists({
    int page = 1,
    int currentListLength = 0,
  });

  Future<List<BaseVideoModelDb>> getPlaylistVideos({
    int page = 1,
    int currentListLength = 0,
    PlaylistModelDb? playlistModelDb,
  });

  Future<List<BaseVideoModelDb>> getAllLikesLength();

  Future<List<BaseVideoModelDb>> getLikedVideos({
    int page = 1,
    int currentListLength = 0,
  });
}
