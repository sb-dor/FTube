import 'dart:convert';
import 'dart:isolate';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/blocs_and_cubits/cubits/video_category_cubit/video_category_cubit_states.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/pages/home_screen/bloc/cubits/home_screen_videos_cubit/home_screen_videos_cubit.dart';
import 'package:youtube/pages/home_screen/bloc/home_screen_bloc_states.dart';
import 'package:youtube/pages/home_screen/bloc/home_screen_state_model/home_screen_state_model.dart';
import 'package:youtube/pages/home_screen/data/repository/abs_home_screen_get_videos.dart';
import 'package:youtube/pages/home_screen/data/sources/rest_api_home_screen.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/youtube_data_api/models/video_data.dart' as ytvdata;

import 'home_screen_bloc_events.dart';

class MainHomeScreenBloc extends Bloc<HomeScreenBlocEvents, HomeScreenStates> {
  late HomeScreenStateModel currentState;

  MainHomeScreenBloc() : super(InitialHomeScreenState(HomeScreenStateModel())) {
    currentState = state.homeScreenStateModel;

    on<RefreshHomeScreenEvent>((event, emit) async => await refreshHomeScreen(event, emit),
        transformer: restartable());

    on<PaginateHomeScreenEvent>((event, emit) async => await paginateHomeScreen(event, emit),
        transformer: concurrent());

    on<SelectVideoCategoryEvent>((event, emit) async => await selectVideoCategoryEvent(event, emit),
        transformer: droppable());
  }

  Future<void> refreshHomeScreen(
      RefreshHomeScreenEvent event, Emitter<HomeScreenStates> emit) async {
    var homeScreenVideosCubit = BlocProvider.of<HomeScreenVideosCubit>(event.context);
    var categoriesCubit = BlocProvider.of<MainVideoCategoryCubit>(event.context);
    homeScreenVideosCubit.loadingHomeScreenVideosState();
    var data = await currentState.homeScreenApi(RestApiHomeScreen()).homeScreenGetVideo(
          q: currentState.videoCategory?.videoCategorySnippet?.title,
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
      currentState.getAndPaginate(list: videos);
      emitState(emit);
      homeScreenVideosCubit.loadedHomeScreenVideosState();

      Map<String, dynamic> toIsolateData = {
        "list": videos.map((e) => e.toJson()).toList(),
      };

      var toIsolateString = jsonEncode(toIsolateData);

      final rp = ReceivePort();

      Isolate.spawn(_getVideosDataIsolateCommunicator, rp.sendPort);

      final broadCastRp = rp.asBroadcastStream();

      final SendPort communicatorPort = await broadCastRp.first;

      communicatorPort.send(toIsolateString);

      broadCastRp.listen((event) {
        ytvdata.VideoData? videoData;
        if(event != null) videoData = ytvdata.VideoData.fromJson(event);
        for (var each in videos) {
          if (each.videoId == videoData?.video?.videoId) {
            each.loadingVideoData = false;
            each.videoData = videoData?.clone();
          }
        }
        debugPrint("event coming: $event");
        homeScreenVideosCubit.loadedHomeScreenVideosState();
      });

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
      PaginateHomeScreenEvent event, Emitter<HomeScreenStates> emit) async {
    if (!currentState.hasMore) return;
    var data = await currentState.homeScreenApi(RestApiHomeScreen()).homeScreenGetVideo(
          q: currentState.videoCategory?.videoCategorySnippet?.title,
        );
    if (data.containsKey('server_error')) {
      //error
    } else if (data.containsKey('success')) {
      List<ytv.Video> videos = data['videos'];
      currentState.getAndPaginate(list: videos, paginate: true);
      emitState(emit);
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
