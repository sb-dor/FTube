import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';

abstract class HistoryInnerScreenDataSource {
  Future<List<BaseVideoModelDb>> getHistory({int page = 1, int currentListLength = 0});
}
