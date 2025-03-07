import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/core/youtube_data_api/models/video_data.dart';
import 'similar_videos_states.dart';

class SimilarVideosCubit extends Cubit<SimilarVideosStates> {
  late SimilarVideoStateModel _currentState;

  SimilarVideosCubit() : super(LoadingSimilarVideosState(SimilarVideoStateModel())) {
    _currentState = state.similarVideoStateModel;
  }

  void loadingSimilarVideosState() => emit(LoadingSimilarVideosState(_currentState));

  void errorSimilarVideosState() => emit(ErrorSimilarVideosState(_currentState));

  void loadedSimilarVideosState() => emit(LoadedSimilarVideosState(_currentState));

  void clearAndSetLoadingState() {
    _currentState.similarVideos.clear();
    _currentState.hasMore = true;
    loadingSimilarVideosState();
  }

  void clearAndSerErrorState() {
    _currentState.similarVideos.clear();
    errorSimilarVideosState();
  }

  void addVideosAndSetLoadedState(List<Video> videos) {
    _currentState.similarVideos.addAll(videos);
    loadedSimilarVideosState();
  }

  void changeVideoData(VideoData? videoData) {
    for (var each in _currentState.similarVideos) {
      if (each.videoId == videoData?.video?.videoId) {
        each.loadingVideoData = false;
        each.videoData = videoData?.clone();
      }
    }
    loadedSimilarVideosState();
  }

  void _emitter() {
    if (state is LoadingSimilarVideosState) {
      emit(LoadingSimilarVideosState(_currentState));
    } else if (state is ErrorSimilarVideosState) {
      emit(ErrorSimilarVideosState(_currentState));
    } else if (state is LoadedSimilarVideosState) {
      emit(LoadedSimilarVideosState(_currentState));
    }
  }
}
