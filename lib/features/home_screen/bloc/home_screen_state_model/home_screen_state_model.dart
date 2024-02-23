import 'package:flutter/cupertino.dart';
import 'package:youtube/features/home_screen/data/repository/abs_home_screen_get_videos.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;

class HomeScreenStateModel {
  final globalFunc = locator<ReusableGlobalFunctions>();

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
    debugPrint("has more? :$hasMore");
  }

  AbsHomeScreenGetVideos homeScreenApi(AbsHomeScreenGetVideos homeScreen) => homeScreen;
}
