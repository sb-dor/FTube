import 'package:flutter/cupertino.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart' as ytv;

class HomeScreenStateModel {
  final globalFunc = ReusableGlobalFunctions.instance;

  bool paginating = false, hasMore = false;
  VideoCategory? videoCategory;
  List<ytv.Video> videos = [];

  void getAndPaginate({required List<ytv.Video> list, bool paginate = false}) {
    if (paginate) {
      videos.addAll(list);
    } else {
      videos = list;
    }
    hasMore = globalFunc.checkIsListHasMorePageBool(list: list);
    // debugPrint"has more? :$hasMore");
  }

}
