import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';

class GetPlaylist {
  final LibraryScreenRepository _libraryScreenRepository;

  GetPlaylist(this._libraryScreenRepository);

  Future<List<PlaylistModelDb>> getPlaylist({int page = 1}) =>
      _libraryScreenRepository.getPlaylists(page: page);
}
