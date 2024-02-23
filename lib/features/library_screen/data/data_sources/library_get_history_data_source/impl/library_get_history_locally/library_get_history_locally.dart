import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/library_get_history_data_source.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class LibraryGetHistoryLocally implements LibraryGetHistoryDataSource {
  @override
  Future<List<VideoModelDb>> getHistory({int page = 1}) async {
    var data = <VideoModelDb>[];
    if (page == 1) data = await locator<DbFloor>().videoDbDao.getLimitVideos(15);
    return data;
  }
}
