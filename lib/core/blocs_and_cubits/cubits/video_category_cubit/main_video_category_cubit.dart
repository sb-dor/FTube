import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/home_screen/data/repository/abs_home_screen_get_categories.dart';
import 'package:youtube/features/home_screen/data/sources/rest_api_home_screen_get_gategories.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/models/video_category_models/video_category_snippet.dart';

import 'video_category_cubit_states.dart';

class MainVideoCategoryCubit extends Cubit<VideoCategoryCubitStates> {
  List<VideoCategory> videoCategories = [];

  MainVideoCategoryCubit() : super(LoadingVideoCategoryState()) {
    loadVideoCategory();
  }

  Future<void> loadVideoCategory() async {
    debugPrint("loading categories");
    videoCategories.clear();
    emit(LoadingVideoCategoryState());
    var data = await AbsHomeScreenGetCategories(RestApiHomeScreenGetCategories()).getCategories();
    if (data.containsKey("server_error")) {
      emit(ErrorVideoCategoryState());
    } else if (data.containsKey("success")) {
      videoCategories = data['categories'];
      if (videoCategories.isNotEmpty) {
        videoCategories.insert(
            0, VideoCategory(id: null, videoCategorySnippet: VideoCategorySnippet(title: "All")));
      }
      emit(LoadedVideoCategoryState());
    } else {
      emit(ErrorVideoCategoryState());
    }
  }
}
