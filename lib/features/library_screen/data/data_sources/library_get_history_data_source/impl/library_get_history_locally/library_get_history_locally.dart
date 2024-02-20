import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/library_get_history_data_source.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class LibraryGetHistoryLocally implements LibraryGetHistoryDataSource {
  @override
  Future<List<Video>> getHistory({int page = 1}) async {
    return <Video>[];
  }
}
