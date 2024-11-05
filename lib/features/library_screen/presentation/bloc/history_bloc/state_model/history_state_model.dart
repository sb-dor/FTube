import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';

class HistoryStateModel {
  final _globalFunctions = locator<ReusableGlobalFunctions>();

  int lengthOfDownloadedFiles = 0;

  List<BaseVideoModelDb> videos = [];

  int page = 1;

  bool hasMore = false;

  void addPaginate({required List<BaseVideoModelDb> videos, bool paginate = false}) {
    if (paginate) {
      this.videos.addAll(videos);
    } else {
      this.videos = videos;
    }

    page = _globalFunctions.checkIsListHasMorePageInt(list: videos, page: page);

    hasMore = _globalFunctions.checkIsListHasMorePageBool(list: videos);
  }
}
