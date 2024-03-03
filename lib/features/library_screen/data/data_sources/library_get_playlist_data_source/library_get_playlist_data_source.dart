import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

abstract class LibraryGetPlaylistDataSource {
  Future<List<PlaylistModelDb>> getPlaylists({int page = 1});
}
