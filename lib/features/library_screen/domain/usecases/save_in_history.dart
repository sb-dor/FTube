import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';

class SaveInHistory {
  final LibraryScreenRepository _libraryScreenRepository;

  SaveInHistory(this._libraryScreenRepository);

  Future<void> saveInHistory(Video? video) => _libraryScreenRepository.saveInHistory(video);
}
