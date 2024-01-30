import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_gaming.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_movies.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_music.dart';
import 'package:youtube/features/trending_screen/domain/usecases/get_trending_videos.dart';
import 'package:youtube/models/video_category_models/video_category.dart';
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
        if (event.category.id != _currentState.category.id) _currentState.category = event.category;

        _currentState.videos.clear();

        emit(LoadingTrendingScreenState(_currentState));

        if (event.category.id == '1') {
          _currentState.videos = await _getTrendingGaming.getTrendingGaming();
        } else if (event.category.id == '2') {
          _currentState.videos = await _getTrendingMovies.getTrendingMovies();
        } else if (event.category.id == '3') {
          _currentState.videos = await _getTrendingMusic.getTrendingMusic();
        } else {
          _currentState.videos = await _getTrendingVideos.getTrendingVideos();
        }

        emit(LoadedTrendingScreenState(_currentState));
      } catch (e) {
        emit(ErrorTrendingScreenState("$e", state.trendingStateModel));
      }
    });

    on<PaginateTrendingScreen>((event, emit) {});
  }
}
