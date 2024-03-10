import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository/playlist_inner_screen_repository.dart';

class GetAllPlaylistsUsecase {
  final PlaylistInnerScreenRepository _playlistInnerScreenRepository;

  GetAllPlaylistsUsecase(
    this._playlistInnerScreenRepository,
  );

  Future<List<PlaylistModelDb>> getAllPlaylists({int page = 1, int currentListLength = 0}) =>
      _playlistInnerScreenRepository.getPlaylists(
        page: page,
        currentListLength: currentListLength,
      );
}
