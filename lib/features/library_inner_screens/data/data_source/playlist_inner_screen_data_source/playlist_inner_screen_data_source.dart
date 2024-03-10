import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';

abstract class PlaylistInnerScreenDataSource {
  Future<List<PlaylistModelDb>> getPlaylists({int page = 1, int currentListLength = 0});
}
