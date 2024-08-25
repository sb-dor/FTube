import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';

class GetLikedVideos {
  final LibraryScreenRepository _libraryScreenRepository;

  GetLikedVideos(this._libraryScreenRepository);

  Future<List<BaseVideoModelDb>> getLikedVideos() => _libraryScreenRepository.getLikedVideo();
}
