import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/library_create_playlist_data_source.dart';

class LibraryCreatePlaylistLocally implements LibraryCreatePlaylistDataSource {
  final DbFloor _dbFloor;

  LibraryCreatePlaylistLocally(this._dbFloor);

  @override
  Future<void> createPlayList(String name) async {
    final PlaylistModelDb playlistModelDb = PlaylistModelDb(
      name: name,
    );

    await _dbFloor.playListDao.createPlaylist(playlistModelDb);
  }
}
