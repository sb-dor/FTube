import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/cubits/home_screen_videos_cubit/home_screen_videos_states.dart';

class HomeScreenVideosCubit extends Cubit<HomeScreenVideosStates> {
  HomeScreenVideosCubit() : super(LoadingHomeScreenVideosState());

  void loadingHomeScreenVideosState() => emit(LoadingHomeScreenVideosState());

  void errorHomeScreenVideosState() => emit(ErrorHomeScreenVideosState());

  void loadedHomeScreenVideosState() => emit(LoadedHomeScreenVideosState());
}
