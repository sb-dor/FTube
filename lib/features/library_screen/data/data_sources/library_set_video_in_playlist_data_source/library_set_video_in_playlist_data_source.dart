import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

abstract class LibrarySetVideoInPlaylistDataSource {
  Future<void> setVideoInPlaylist(
    BaseVideoModelDb? video,
    PlaylistModelDb? playlistModelDb,
  );
}
