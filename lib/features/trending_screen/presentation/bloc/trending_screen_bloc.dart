import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_gaming.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_movies.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_music.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_videos.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

import 'state_model/trending_state_model.dart';

part 'trending_screen_event.dart';

part 'trending_screen_state.dart';

class TrendingScreenBloc extends Bloc<TrendingScreenEvent, TrendingScreenState> {
  late final TrendingStateModel _currentState;
  late final GetTrendingGaming _getTrendingGaming;
  late final GetTrendingMovies _getTrendingMovies;
  late final GetTrendingMusic _getTrendingMusic;
  late final GetTrendingVideos _getTrendingVideos;
  final TrendsRepository _trendsRepository;

  TrendingScreenBloc(this._trendsRepository)
      : super(LoadingTrendingScreenState(TrendingStateModel())) {
    _currentState = state.trendingStateModel;
    _getTrendingGaming = GetTrendingGaming(_trendsRepository);
    _getTrendingMovies = GetTrendingMovies(_trendsRepository);
    _getTrendingMusic = GetTrendingMusic(_trendsRepository);
    _getTrendingVideos = GetTrendingVideos(_trendsRepository);

    //
    //

    on<RefreshTrendingScreen>((event, emit) async {
      try {
        _currentState.videos.clear();
        LoadingTrendingScreenState(_currentState);

        _currentState.videos = await _getTrendingGaming.getTrendingGaming();
        debugPrint("current list length: ${_currentState.videos.length}");

        emit(LoadedTrendingScreenState(_currentState));
      } catch (e) {
        emit(ErrorTrendingScreenState("$e", state.trendingStateModel));
      }
    });

    on<PaginateTrendingScreen>((event, emit) {});
  }
}
