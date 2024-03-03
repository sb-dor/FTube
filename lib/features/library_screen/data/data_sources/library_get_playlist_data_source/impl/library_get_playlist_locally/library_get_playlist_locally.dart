import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class LibraryGetPlaylistLocally implements LibraryGetPlaylistDataSource {
  @override
  Future<List<PlaylistModelDb>> getPlaylists({int page = 1}) async {
    final dbOfPlaylists = locator<DbFloor>().playListDao;

    var playlists = await dbOfPlaylists.getAllPlaylists();

    for (int i = 0; i < playlists.length; i++) {
      playlists[i].videos = await dbOfPlaylists.getPlaylistAllVideos(playlists[i].id ?? 0);
      playlists[i].videos = playlists[i].videos?.reversed.toList();
    }

    playlists = playlists.reversed.toList();

    return playlists;
  }
}
