import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/library_create_playlist_data_source.dart';

class LibraryCreatePlaylistLocally implements LibraryCreatePlaylistDataSource {
  @override
  Future<void> createPlayList(String name) async {
    final PlaylistModelDb playlistModelDb = PlaylistModelDb(
      name: name,
    );

    await locator<DbFloor>().playListDao.createPlaylist(playlistModelDb);
  }
}
