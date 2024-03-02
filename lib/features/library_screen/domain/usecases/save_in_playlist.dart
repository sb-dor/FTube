import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';

class SaveInPlaylist {
  final LibraryScreenRepository _libraryScreenRepository;

  SaveInPlaylist(this._libraryScreenRepository);

  Future<void> saveInPlaylist(BaseVideoModelDb? video, PlaylistModelDb? playlistModelDb) =>
      _libraryScreenRepository.saveInPlayList(video, playlistModelDb);
}
