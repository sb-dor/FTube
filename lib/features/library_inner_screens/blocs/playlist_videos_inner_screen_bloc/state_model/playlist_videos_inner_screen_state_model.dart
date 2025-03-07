import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';

class PlaylistVideosInnerScreenStateModel {
  final ReusableGlobalFunctions _globalFunctions = ReusableGlobalFunctions.instance;

  List<BaseVideoModelDb> playlistVideos = [];

  int page = 1;

  bool hasMore = false;

  void addPaginate({required List<BaseVideoModelDb> videos, bool paginate = false}) {
    if (paginate) {
      playlistVideos.addAll(videos);
    } else {
      playlistVideos = videos;
    }

    page = _globalFunctions.checkIsListHasMorePageInt(list: videos, page: page);

    hasMore = _globalFunctions.checkIsListHasMorePageBool(list: videos);
  }
}
