import 'dart:convert';
import 'dart:isolate';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';
import 'package:youtube/blocs_and_cubits/home_page_bottom_navbar_cubit/home_page_bottom_navbar_cubit.dart';
import 'package:youtube/features/home_screen/data/sources/rest_api_home_screen.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/youtube_data_api/models/video_data.dart' as ytvdata;

import 'cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'home_screen_bloc_events.dart';
import 'home_screen_bloc_states.dart';
import 'home_screen_state_model/home_screen_state_model.dart';

class MainHomeScreenBloc extends Bloc<HomeScreenBlocEvents, HomeScreenStates> {
  late HomeScreenStateModel _currentState;

  MainHomeScreenBloc() : super(InitialHomeScreenState(HomeScreenStateModel())) {
    _currentState = state.homeScreenStateModel;

    on<RefreshHomeScreenEvent>((event, emit) async => await refreshHomeScreen(event, emit),
        transformer: restartable());

    on<PaginateHomeScreenEvent>((event, emit) async => await paginateHomeScreen(event, emit),
        transformer: concurrent());

    on<SelectVideoCategoryEvent>((event, emit) async => await selectVideoCategoryEvent(event, emit),
        transformer: droppable());
  }

  Future<void> refreshHomeScreen(
      RefreshHomeScreenEvent event, Emitter<HomeScreenStates> emit) async {
    if (_currentState.videoCategory != null) {
      event.scrollController?.animateTo(
        0.0,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      BlocProvider.of<HomePageBottomNavbarCubit>(event.context).showBottomNavbar();
    }

    var homeScreenVideosCubit = BlocProvider.of<HomeScreenVideosCubit>(event.context);

    var categoriesCubit = BlocProvider.of<MainVideoCategoryCubit>(event.context);

    homeScreenVideosCubit.loadingHomeScreenVideosState();

    var data = await _currentState.homeScreenApi(RestApiHomeScreen()).homeScreenGetVideo(
          q: _currentState.videoCategory?.id == null
              ? null
              : _currentState.videoCategory?.videoCategorySnippet?.title,
          clearSearch: true,
        );

    if (categoriesCubit.state is ErrorVideoCategoryState) {
      categoriesCubit.loadVideoCategory();
    }

    if (data.containsKey("server_error")) {
      // server error
      homeScreenVideosCubit.errorHomeScreenVideosState();
    } else if (data.containsKey("success")) {
      List<ytv.Video> videos = data['videos'];
      _currentState.getAndPaginate(list: videos);
      emitState(emit);
      homeScreenVideosCubit.loadedHomeScreenVideosState();

      await _getVideosDataIsolate(
        videos: videos,
        emit: emit,
      );

      debugPrint("is coming here");

      emitState(emit);
      homeScreenVideosCubit.loadedHomeScreenVideosState();
    } else {
      homeScreenVideosCubit.errorHomeScreenVideosState();
      // server error
    }
    emitState(emit);
  }

  Future<void> paginateHomeScreen(
    PaginateHomeScreenEvent event,
    Emitter<HomeScreenStates> emit,
  ) async {
    if (!_currentState.hasMore) return;

    if (_currentState.paginating) return;

    _currentState.paginating = true;

    var data = await _currentState.homeScreenApi(RestApiHomeScreen()).homeScreenGetVideo(
          q: _currentState.videoCategory?.videoCategorySnippet?.title,
        );

    _currentState.paginating = false;

    if (data.containsKey('server_error')) {
      //error
    } else if (data.containsKey('success')) {
      List<ytv.Video> videos = data['videos'];
      _currentState.getAndPaginate(list: videos, paginate: true);
      emitState(emit);

      await _getVideosDataIsolate(videos: videos, emit: emit);

      emitState(emit);
    }
    emitState(emit);
  }

  Future<void> selectVideoCategoryEvent(
      SelectVideoCategoryEvent event, Emitter<HomeScreenStates> emit) async {
    if (_currentState.videoCategory?.id == event.videoCategory?.id) return;
    _currentState.videoCategory = event.videoCategory;
    add(RefreshHomeScreenEvent(
      context: event.context,
      videoCategory: _currentState.videoCategory,
      scrollController: event.scrollController,
    ));
    emitState(emit);
  }

  void emitState(Emitter<HomeScreenStates> emit) {
    if (state is InitialHomeScreenState) {
      emit(InitialHomeScreenState(_currentState));
    } else if (state is ErrorHomeScreenState) {
      emit(ErrorHomeScreenState(_currentState));
    }
  }

  Future<void> _getVideosDataIsolate(
      {required List<ytv.Video> videos, required Emitter<HomeScreenStates> emit}) async {
    Map<String, dynamic> toIsolateData = {
      "list": videos.map((e) => e.toJson()).toList(),
    };

    var toIsolateString = jsonEncode(toIsolateData);

    final rp = ReceivePort();

    Isolate.spawn(_getVideosDataIsolateCommunicator, rp.sendPort);

    final broadCastRp = rp.asBroadcastStream();

    final SendPort communicatorPort = await broadCastRp.first;

    communicatorPort.send(toIsolateString);

    await for (final each in broadCastRp) {
      ytvdata.VideoData? videoData;
      if (each != null) videoData = ytvdata.VideoData.fromJson(each);
      for (var each in videos) {
        if (each.videoId == videoData?.video?.videoId) {
          each.loadingVideoData = false;
          each.videoData = videoData?.clone();
        }
      }
      debugPrint("event coming: $each");
      emitState(emit);
    }
  }

  static void _getVideosDataIsolateCommunicator(SendPort sp) async {
    final rp = ReceivePort();
    sp.send(rp.sendPort);

    final message = rp.takeWhile((el) => el is String).cast<String>();

    await for (var each in message) {
      Map<String, dynamic> data = jsonDecode(each);

      List<dynamic> list = [];

      if (data['list'] != null) {
        list = data['list'];
      }

      List<ytv.Video> videoList = list.map((e) => ytv.Video.fromIsolate(e)).toList();

      await Future.wait(
        videoList.map(
          (e) => e.getVideoData().then((_) => sp.send(e.videoData?.toJson())),
        ),
      );
    }
  }
}
