import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class HistoryInnerScreenStateModel {
  final ReusableGlobalFunctions _globalFunctions = locator<ReusableGlobalFunctions>();

  List<BaseVideoModelDb> historyVideos = [];

  int page = 1;

  bool hasMore = false;

  void addPaginate({required List<BaseVideoModelDb> videos, bool paginate = false}) {
    if (paginate) {
      historyVideos.addAll(videos);
    } else {
      historyVideos = videos;
    }

    page = _globalFunctions.checkIsListHasMorePageInt(list: videos, page: page);

    hasMore = _globalFunctions.checkIsListHasMorePageBool(list: videos);
  }
}
