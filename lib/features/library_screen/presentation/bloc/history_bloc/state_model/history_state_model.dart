import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class HistoryStateModel {
  final _globalFunctions = locator<ReusableGlobalFunctions>();

  List<VideoModelDb> videos = [];

  int page = 1;

  bool hasMore = false;

  void addPaginate({required List<VideoModelDb> videos, bool paginate = false}) {
    if (paginate) {
      this.videos.addAll(videos);
    } else {
      this.videos = videos;
    }

    page = _globalFunctions.checkIsListHasMorePageInt(list: videos, page: page);

    hasMore = _globalFunctions.checkIsListHasMorePageBool(list: videos);
  }
}
