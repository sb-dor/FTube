import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import 'state_model/top_overlay_feature_state_model.dart';
import 'top_overlay_feature_events.dart';
import 'top_overlay_feature_states.dart';

class TopOverlayFeatureBloc extends Bloc<TopOverlayFeatureEvents, TopOverlayFeatureStates> {
  late final TopOverlayFeatureStateModel _currentState;

  TopOverlayFeatureBloc() : super(LoadingOverlayFeatureState(TopOverlayFeatureStateModel())) {
    //
    _currentState = state.topOverlayFeatureStateModel;

    //
    on<InitOverlayVideoController>(_initOverlayVideoController);

    on<ConvertToLoadingState>((event, emit) {
      _currentState.initController(null);
      emit(LoadingOverlayFeatureState(_currentState));
    });

    on<PlayAndPauseVideoEvent>(_playAndPauseVideoEvent);

    on<ShowAndHideButtonsOnClickEvent>(_showAndHideButtonsOnClickEvent);
  }

  void _initOverlayVideoController(
    InitOverlayVideoController event,
    Emitter<TopOverlayFeatureStates> emit,
  ) async {
    try {
      debugPrint("test coming here");
      await _currentState.disposeController();
      LoadingOverlayFeatureState(_currentState);
      _currentState.initController(
        VideoPlayerController.networkUrl(
          Uri.parse(event.videoUrl),
        ),
      );
      await _currentState.playerController?.initialize();
      await _currentState.playerController?.seekTo(event.position ?? const Duration());
      await _currentState.playerController?.play();
      debugPrint("loaded coming here 3");
      emit(LoadedOverlayFeatureState(_currentState));
    } catch (e) {
      debugPrint("overlay error is url: ${event.videoUrl} | $e");
    }
  }



  void _playAndPauseVideoEvent(
    PlayAndPauseVideoEvent event,
    Emitter<TopOverlayFeatureStates> emit,
  ) async {
    _currentState.setValueToPlaying(!_currentState.isPlaying);

    if (_currentState.isPlaying) {
      _currentState.playerController?.play();
    } else {
      _currentState.playerController?.pause();
    }
  }

  void _showAndHideButtonsOnClickEvent(
    ShowAndHideButtonsOnClickEvent event,
    Emitter<TopOverlayFeatureStates> emit,
  ) async {
    await _currentState.changeShowButtons(
      () {
        emit(LoadedOverlayFeatureState(_currentState));
      },
    );
  }


  @override
  Future<void> close() async {
    await _currentState.disposeController();
    return super.close();
  }
}
