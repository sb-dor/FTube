import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/api/api_env.dart';
import 'package:youtube/api/api_home_screen/rest_api_home_screen.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/home_screen_bloc_states.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/home_screen_state_model/home_screen_state_model.dart';
import 'package:youtube/models/video_modes/video.dart';

import 'home_screen_bloc_events.dart';

class MainHomeScreenBloc extends Bloc<HomeScreenBlocEvents, HomeScreenStates> {
  late HomeScreenStateModel currentState;

  MainHomeScreenBloc() : super(InitialHomeScreenState(HomeScreenStateModel())) {
    currentState = state.homeScreenStateModel;

    on<RefreshHomeScreenEvent>((event, emit) => refreshHomeScreen(event, emit),
        transformer: droppable());

    on<PaginateHomeScreenEvent>((event, emit) => paginateHomeScreen(event, emit),
        transformer: droppable());

    on<SelectVideoCategoryEvent>((event, emit) => selectVideoCategoryEvent(event, emit),
        transformer: droppable());
  }

  Future<void> refreshHomeScreen(
      RefreshHomeScreenEvent event, Emitter<HomeScreenStates> emit) async {
    var homeScreenVideosCubit = BlocProvider.of<HomeScreenVideosCubit>(event.context);
    homeScreenVideosCubit.loadingHomeScreenVideosState();
    var data =
        await RestApiHomeScreen.homeScreenGetVideo(videoCategoryId: currentState.videoCategory?.id);

    if (data.containsKey("server_error")) {
      // server error
      homeScreenVideosCubit.errorHomeScreenVideosState();
    } else if (data.containsKey("success")) {
      currentState.nextPageToken = data['next_page_token'];
      List<Video> videos = data['videos'];
      currentState.getAndPaginate(list: videos);
      emitState(emit);
      homeScreenVideosCubit.loadedHomeScreenVideosState();
      for (var element in videos) {
        await element.snippet?.loadChannel();
      }
    } else {
      homeScreenVideosCubit.errorHomeScreenVideosState();
      // server error
    }
    emitState(emit);
  }

  Future<void> paginateHomeScreen(
      PaginateHomeScreenEvent event, Emitter<HomeScreenStates> emit) async {
    if (!currentState.hasMore) return;
    var data = await RestApiHomeScreen.homeScreenGetVideo(
        page: currentState.nextPageToken, videoCategoryId: currentState.videoCategory?.id);
    if (data.containsKey('server_error')) {
      //error
    } else if (data.containsKey('success')) {
      currentState.nextPageToken = data['next_page_token'];
      List<Video> videos = data['videos'];
      currentState.getAndPaginate(list: videos, paginate: true);
      emitState(emit);
      for (var element in videos) {
        await element.snippet?.loadChannel();
      }
    }
    emitState(emit);
  }

  Future<void> selectVideoCategoryEvent(
      SelectVideoCategoryEvent event, Emitter<HomeScreenStates> emit) async {
    if (currentState.videoCategory?.id == event.videoCategory?.id) return;
    currentState.videoCategory = event.videoCategory;
    add(RefreshHomeScreenEvent(context: event.context, videoCategory: currentState.videoCategory));
    emitState(emit);
  }

  void emitState(Emitter<HomeScreenStates> emit) {
    if (state is InitialHomeScreenState) {
      emit(InitialHomeScreenState(currentState));
    } else if (state is ErrorHomeScreenState) {
      emit(ErrorHomeScreenState(currentState));
    }
  }
}
