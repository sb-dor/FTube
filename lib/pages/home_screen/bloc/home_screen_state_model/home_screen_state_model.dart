import 'package:flutter/cupertino.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/pages/home_screen/data/rest_api_home_screen.dart';
import 'package:youtube/utils/reusable_global_functions.dart';

class HomeScreenStateModel {
  final globalFunc = ReusableGlobalFunctions.instance;
  final restApiHomeScreen = RestApiHomeScreen.instance;

  String nextPageToken = '';
  bool hasMore = false;
  VideoCategory? videoCategory;
  List<Video> videos = [];

  void getAndPaginate({required List<Video> list, bool paginate = false}) {
    if (paginate) {
      videos.addAll(list);
    } else {
      videos = list;
    }
    hasMore = globalFunc.checkIsListHasMorePageBool(list: list);
    debugPrint("has more? :$hasMore");
  }
}
