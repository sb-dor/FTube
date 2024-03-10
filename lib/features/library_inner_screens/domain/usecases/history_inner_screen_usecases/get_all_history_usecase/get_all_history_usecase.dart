import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/history_inner_screen_repository/history_inner_screen_repository.dart';

class GetAllHistoryUsecase {
  final HistoryInnerScreenRepository _historyInnerScreenRepository;

  GetAllHistoryUsecase(this._historyInnerScreenRepository);

  Future<List<BaseVideoModelDb>> getAllHistory({int page = 1, int currentListLength = 0}) =>
      _historyInnerScreenRepository.getHistory(
        page: page,
        currentListLength: currentListLength,
      );
}
