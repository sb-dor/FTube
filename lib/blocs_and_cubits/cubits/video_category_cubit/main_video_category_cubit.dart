import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';
import 'package:youtube/models/video_category_models/video_category.dart';

class MainVideoCategoryCubit extends Cubit<VideoCategoryCubitStates> {
  MainVideoCategoryCubit() : super(LoadingVideoCategoryState());

  List<VideoCategory> videoCategories = [];

  Future<void> loadVideoCategory() async {}
}
