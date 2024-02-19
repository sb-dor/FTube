import 'package:youtube/youtube_data_api/models/playlist.dart';

abstract class LibraryGetPlaylistDataSource {
  Future<List<PlayList>> getPlaylists();
}
