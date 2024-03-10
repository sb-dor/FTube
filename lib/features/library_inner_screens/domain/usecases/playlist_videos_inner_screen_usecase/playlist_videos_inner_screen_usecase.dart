import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository/playlist_inner_screen_repository.dart';

class PlaylistVideosInnerScreenUsecase {
  final PlaylistInnerScreenRepository _playlistInnerScreenRepository;

  PlaylistVideosInnerScreenUsecase(this._playlistInnerScreenRepository);

  Future<List<BaseVideoModelDb>> getPlaylistVideos({
    int page = 1,
    int currentListLength = 0,
    PlaylistModelDb? playlistModelDb,
  }) =>
      _playlistInnerScreenRepository.getPlaylistVideos(
        page: page,
        currentListLength: currentListLength,
        playlistModelDb: playlistModelDb,
      );
}
