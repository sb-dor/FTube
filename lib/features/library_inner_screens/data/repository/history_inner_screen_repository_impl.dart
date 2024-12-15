import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/history_inner_screen_data_source/history_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/history_inner_screen_repository.dart';

class HistoryInnerScreenRepositoryImpl implements HistoryInnerScreenRepository {
  final HistoryInnerScreenDataSource _historyInnerScreenDataSource;

  HistoryInnerScreenRepositoryImpl(
    this._historyInnerScreenDataSource,
  );

  @override
  Future<List<BaseVideoModelDb>> getHistory({int page = 1, int currentListLength = 0}) =>
      _historyInnerScreenDataSource.getHistory(
        page: page,
        currentListLength: currentListLength,
      );
}
