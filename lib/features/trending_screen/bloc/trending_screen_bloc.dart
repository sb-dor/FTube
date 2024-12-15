import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/core/youtube_data_api/models/video_data.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'state_model/trending_state_model.dart';

part 'trending_screen_event.dart';

part 'trending_screen_state.dart';

class TrendingScreenBloc extends Bloc<TrendingScreenEvent, TrendingScreenState> {
  late final TrendingStateModel _currentState;
  final TrendsRepository _trendsRepository;

  TrendingScreenBloc(this._trendsRepository)
      : super(LoadingTrendingScreenState(TrendingStateModel())) {
    _currentState = state.trendingStateModel;

    //
    //

    on<RefreshTrendingScreen>((event, emit) async {
      if (state is LoadedTrendingScreenState && event.refresh == false) return;

      try {
        if (event.category.id != _currentState.category.id) _currentState.category = event.category;

        _currentState.videos.clear();

        emit(LoadingTrendingScreenState(_currentState));

        if (event.category.id == '1') {
          _currentState.videos = await _trendsRepository.fetchTrendingGaming();
        } else if (event.category.id == '2') {
          _currentState.videos = await _trendsRepository.fetchTrendingMovies();
        } else if (event.category.id == '3') {
          _currentState.videos = await _trendsRepository.fetchTrendingMusic();
        } else {
          _currentState.videos = await _trendsRepository.fetchTrendingVideo();
        }

        emit(LoadedTrendingScreenState(_currentState));

        // await _getInfoFromIsolate(_currentState.videos, emit);
      } catch (e) {
        emit(ErrorTrendingScreenState("$e", state.trendingStateModel));
      }
    });
  }

  void _emitState(Emitter<TrendingScreenState> emit) {
    if (state is LoadingTrendingScreenState) {
      emit(LoadingTrendingScreenState(_currentState));
    } else if (state is ErrorTrendingScreenState) {
      emit(ErrorTrendingScreenState("Error state", _currentState));
    } else if (state is LoadedTrendingScreenState) {
      emit(LoadedTrendingScreenState(_currentState));
    }
  }

  Future<void> _getInfoFromIsolate(
    List<Video> videos,
    Emitter<TrendingScreenState> emit,
  ) async {
    Map<String, dynamic> toIsolateData = {
      "list": videos.map((e) => e.toJson()).toList(),
    };

    final jsonToString = jsonEncode(toIsolateData);

    final receivePort = ReceivePort();

    Isolate.spawn(_isolate, receivePort.sendPort);

    final broadCast = receivePort.asBroadcastStream();

    final SendPort communicator = await broadCast.first;

    communicator.send(jsonToString);

    await for (final each in broadCast) {
      VideoData? videoData;
      if (each != null) videoData = VideoData.fromJson(each);
      for (var each in videos) {
        if (each.videoId == videoData?.video?.videoId) {
          each.loadingVideoData = false;
          each.videoData = videoData?.clone();
        }
      }
      // debugPrint("event coming trending screen: $each");
      _emitState(emit);
    }
  }

  static void _isolate(SendPort sendPort) async {
    final isolateRp = ReceivePort();
    sendPort.send(isolateRp.sendPort);

    final message = isolateRp.takeWhile((element) => element is String).cast<String>();

    await for (final each in message) {
      Map<String, dynamic> json = jsonDecode(each);

      List<dynamic> list = [];

      if (json.containsKey('list')) list = json['list'];

      List<Video> isolateVideos = list.map((e) => Video.fromIsolate(e)).toList();

      YoutubeDataApi youtubeDataApi = YoutubeDataApi();

      await Future.wait(
        isolateVideos.map(
          (e) =>
              e.getVideoData(youtubeDataApi).then((value) => sendPort.send(e.videoData?.toJson())),
        ),
      );
    }
  }
}
