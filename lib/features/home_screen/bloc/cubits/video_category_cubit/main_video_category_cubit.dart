import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/core/models/video_category_models/video_category_snippet.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';
import 'video_category_cubit_states.dart';

class MainVideoCategoryCubit extends Cubit<VideoCategoryCubitStates> {
  final HomeScreenRepo _homeScreenRepo;

  MainVideoCategoryCubit(this._homeScreenRepo)
    : super(LoadingVideoCategoryState(List.empty())) {
    loadVideoCategory();
  }

  Future<void> loadVideoCategory() async {
    // debugPrint"loading categories 1");
    emit(LoadingVideoCategoryState(List.empty()));
    final data = await _homeScreenRepo.getCategories();
    // debugPrint"get categories data: $data");
    if (data.containsKey("server_error")) {
      emit(ErrorVideoCategoryState(List.empty()));
    } else if (data.containsKey("success")) {
      final List<VideoCategory> list = data['categories'];
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
