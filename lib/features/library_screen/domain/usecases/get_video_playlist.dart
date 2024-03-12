import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';

class GetVideoPlaylist {
  final LibraryScreenRepository _libraryScreenRepository;

  GetVideoPlaylist(
    this._libraryScreenRepository,
  );

  Future<PlaylistModelDb?> videoPlaylist(BaseVideoModelDb? baseVideoModelDb) =>
      _libraryScreenRepository.videoPlaylist(baseVideoModelDb);
}
