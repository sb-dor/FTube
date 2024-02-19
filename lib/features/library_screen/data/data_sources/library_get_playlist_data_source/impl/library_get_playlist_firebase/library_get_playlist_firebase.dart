import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/library_get_playlist_data_source.dart';
import 'package:youtube/youtube_data_api/models/playlist.dart';

class LibraryGetPlaylistFirebase implements LibraryGetPlaylistDataSource {
  @override
  Future<List<PlayList>> getPlaylists() async {
    return <PlayList>[];
  }
}
