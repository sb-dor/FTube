import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/history_inner_screen_data_source/history_inner_screen_data_source.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class HistoryInnerScreenDataSourceLocally implements HistoryInnerScreenDataSource {
  @override
  Future<List<BaseVideoModelDb>> getHistory({int page = 1}) async {
    final data = await locator<DbFloor>().videoDbDao.getAllVideos().then(
          (value) => value.reversed.toList(),
        );
    return data;
  }
}
