import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/core/models/video_category_models/video_category_snippet.dart';
import 'package:youtube/features/home_screen/data/repo/home_screen_repo_impl.dart';
import 'package:youtube/features/home_screen/domain/usecases/hs_get_categories.dart';
import 'video_category_cubit_states.dart';

class MainVideoCategoryCubit extends Cubit<VideoCategoryCubitStates> {
  MainVideoCategoryCubit() : super(LoadingVideoCategoryState(List.empty())) {
    loadVideoCategory();
  }

  Future<void> loadVideoCategory() async {
    debugPrint("loading categories 1");
    emit(LoadingVideoCategoryState(List.empty()));
    var data = await HsGetCategories(HomeScreenRepoImpl()).getCategories();
    debugPrint("get categories data: ${data}");
    if (data.containsKey("server_error")) {
      emit(ErrorVideoCategoryState(List.empty()));
    } else if (data.containsKey("success")) {
      List<VideoCategory> list = data['categories'];
      if (list.isNotEmpty) {
        list.insert(
          0,
          VideoCategory(
            id: null,
            videoCategorySnippet: VideoCategorySnippet(title: "All"),
          ),
        );
      }
      emit(LoadedVideoCategoryState(list));
    } else {
      emit(ErrorVideoCategoryState(List.empty()));
    }
  }
}
