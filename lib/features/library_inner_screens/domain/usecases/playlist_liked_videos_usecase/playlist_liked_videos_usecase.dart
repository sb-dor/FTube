import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository/playlist_inner_screen_repository.dart';

class PlaylistLikedVideosUseCase {
  final PlaylistInnerScreenRepository _playlistInnerScreenRepository;

  PlaylistLikedVideosUseCase(
    this._playlistInnerScreenRepository,
  );

  Future<List<BaseVideoModelDb>> getLikedVideosLength() => _playlistInnerScreenRepository.getAllLikesLength();

  Future<List<BaseVideoModelDb>> getLikedVideos({int page = 1, int currentListLength = 0}) =>
      _playlistInnerScreenRepository.getLikedVideos(
          page: page, currentListLength: currentListLength);
}
