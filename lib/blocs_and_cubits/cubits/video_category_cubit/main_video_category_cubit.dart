import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
import 'package:youtube/models/video_category_models/video_category_snippet.dart';
import 'package:youtube/pages/home_screen/data/rest_api_home_screen.dart';

class MainVideoCategoryCubit extends Cubit<VideoCategoryCubitStates> {
  List<VideoCategory> videoCategories = [];

  MainVideoCategoryCubit() : super(LoadingVideoCategoryState()) {
    loadVideoCategory();
  }

  Future<void> loadVideoCategory() async {
    debugPrint("loading categories");
    videoCategories.clear();
    emit(LoadingVideoCategoryState());
    var data = await RestApiHomeScreen.instance.getCategories();
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
