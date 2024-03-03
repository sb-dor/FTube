import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';

abstract class HistoryInnerScreenRepository {
  Future<List<BaseVideoModelDb>> getHistory({int page = 1});
}
