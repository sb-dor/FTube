import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';

class LibraryGetPlaylistFirebase implements LibraryGetPlaylistDataSource {
  @override
  Future<List<PlaylistModelDb>> getPlaylists({int page = 1}) async {
    return <PlaylistModelDb>[];
  }
}
