import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';

abstract class LibraryGetHistoryDataSource {
  Future<List<VideoModelDb>> getHistory({int page = 1});
}
