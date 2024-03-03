import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_screen/domain/repository/library_screen_repository.dart';

class GetHistory {
  final LibraryScreenRepository _libraryScreenRepository;

  GetHistory(this._libraryScreenRepository);

  Future<List<BaseVideoModelDb>> getHistory() => _libraryScreenRepository.getHistory();
}
