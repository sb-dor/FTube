import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class GetHistory {
  final LibraryScreenRepository _libraryScreenRepository;

  GetHistory(this._libraryScreenRepository);

  Future<List<Video>> getHistory() => _libraryScreenRepository.getHistory();
}
