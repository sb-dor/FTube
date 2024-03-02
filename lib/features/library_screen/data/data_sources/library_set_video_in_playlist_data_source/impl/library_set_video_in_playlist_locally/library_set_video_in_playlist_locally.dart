import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_set_video_in_playlist_data_source/library_set_video_in_playlist_data_source.dart';

class LibrarySetVideoInPlaylistLocally implements LibrarySetVideoInPlaylistDataSource {
  @override
  Future<void> setVideoInPlaylist(
    BaseVideoModelDb? video,
    PlaylistModelDb? playlistModelDb,
  ) async {
    // TODO: implement setVideoInPlaylist
    throw UnimplementedError();
  }
}
