import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/library_get_history_data_source.dart';

class LibraryGetHistoryFirebase implements LibraryGetHistoryDataSource {
  @override
  Future<List<VideoModelDb>> getHistory({int page = 1}) async {
    return <VideoModelDb>[];
  }
}
