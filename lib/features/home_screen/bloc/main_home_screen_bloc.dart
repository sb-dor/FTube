import 'dart:convert';
import 'dart:isolate';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/core/youtube_data_api/models/video_data.dart' as ytvdata;
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';
import 'cubits/video_category_cubit/video_category_cubit_states.dart';
import 'home_screen_bloc_events.dart';
import 'home_screen_bloc_states.dart';
import 'home_screen_state_model/home_screen_state_model.dart';

class MainHomeScreenBloc extends Bloc<HomeScreenBlocEvents, HomeScreenStates> {
  late HomeScreenStateModel _currentState;

  final HomeScreenRepo _homeScreenRepo;

  // late final HsGetVideos _hsGetVideos;
  // late final HsGetCategories _hsGetCategories;

  MainHomeScreenBloc(this._homeScreenRepo) : super(InitialHomeScreenState(HomeScreenStateModel())) {
    _currentState = state.homeScreenStateModel;

    // _hsGetVideos = HsGetVideos(_homeScreenRepo);
    // _hsGetCategories = HsGetCategories(_homeScreenRepo);

    on<RefreshHomeScreenEvent>(
      (event, emit) async => await refreshHomeScreen(event, emit),
      transformer: restartable(),
    );

    on<PaginateHomeScreenEvent>(
      (event, emit) async => await paginateHomeScreen(event, emit),
      transformer: concurrent(),
    );

    on<SelectVideoCategoryEvent>(
      (event, emit) async => await selectVideoCategoryEvent(event, emit),
      transformer: droppable(),
    );
  }

  Future<void> refreshHomeScreen(
    RefreshHomeScreenEvent event,
    Emitter<HomeScreenStates> emit,
  ) async {
    if (event.isLoadedHomeScreenVideos && event.refresh == false) return;

    if (_currentState.videoCategory != null) {
      event.scrollController?.animateTo(
        0.0,
        duration: const Duration(seconds: 1),
        curve: Curves.fastOutSlowIn,
      );
      event.showBottomNavbar();
    }

    event.loadingHomeScreenVideosState();

    final data = await _homeScreenRepo.homeScreenGetVideo(
      q: _currentState.videoCategory?.id == null
          ? null
          : _currentState.videoCategory?.videoCategorySnippet?.title,
      clearSearch: true,
    );

    if (event.isErrorVideoCategoryState is ErrorVideoCategoryState) {
      event.loadVideoCategory();
    }

    // debugPrint"coming data from server: $data");

    if (data.containsKey("server_error")) {
      // server error
      event.errorHomeScreenVideosState();
    } else if (data.containsKey("success")) {
      final List<ytv.Video> videos = data['videos'];
      _currentState.getAndPaginate(list: videos);
      emitState(emit);
      event.loadedHomeScreenVideosState();

      // await _getVideosDataIsolate(
      //   videos: videos,
      //   emit: emit,
      // );

      // debugPrint"is coming here");

      emitState(emit);
      event.loadedHomeScreenVideosState();
    } else {
      event.errorHomeScreenVideosState();
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

    final data = await _homeScreenRepo.homeScreenGetVideo(
      q: _currentState.videoCategory?.videoCategorySnippet?.title,
    );

    _currentState.paginating = false;

    if (data.containsKey('server_error')) {
      //error
    } else if (data.containsKey('success')) {
      final List<ytv.Video> videos = data['videos'];
      _currentState.getAndPaginate(list: videos, paginate: true);
      emitState(emit);

      // await _getVideosDataIsolate(videos: videos, emit: emit);

      emitState(emit);
    }
    emitState(emit);
  }

  Future<void> selectVideoCategoryEvent(
    SelectVideoCategoryEvent event,
    Emitter<HomeScreenStates> emit,
  ) async {
    if (_currentState.videoCategory?.id == event.videoCategory?.id) return;
    _currentState.videoCategory = event.videoCategory;
    event.refresh();
    emitState(emit);
  }

  void emitState(Emitter<HomeScreenStates> emit) {
    if (state is InitialHomeScreenState) {
      emit(InitialHomeScreenState(_currentState));
    } else if (state is ErrorHomeScreenState) {
      emit(ErrorHomeScreenState(_currentState));
    }
  }

  Future<void> _getVideosDataIsolate({
    required List<ytv.Video> videos,
    required Emitter<HomeScreenStates> emit,
  }) async {
    final Map<String, dynamic> toIsolateData = {
      "list": videos.map((e) => e.toJson()).toList(),
    };

    final toIsolateString = jsonEncode(toIsolateData);

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
      // debugPrint"event coming: $each");
      emitState(emit);
    }
  }

  static void _getVideosDataIsolateCommunicator(SendPort sp) async {
    final rp = ReceivePort();
    sp.send(rp.sendPort);

    final message = rp.takeWhile((el) => el is String).cast<String>();

    await for (var each in message) {
      final Map<String, dynamic> data = jsonDecode(each);

      List<dynamic> list = [];

      if (data['list'] != null) {
        list = data['list'];
      }

      final List<ytv.Video> videoList = list.map((e) => ytv.Video.fromIsolate(e)).toList();

      await Future.wait(
        videoList.map(
          (e) => e.getVideoData(YoutubeDataApi()).then((_) => sp.send(e.videoData?.toJson())),
        ),
      );
    }
  }
}
