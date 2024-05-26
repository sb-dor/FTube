import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/state_model/top_overlay_feature_state_model.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_events.dart';
import 'package:youtube/features/top_overlay_feature/view/bloc/top_overlay_feature_states.dart';

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
  }

  void _initOverlayVideoController(
    InitOverlayVideoController event,
    Emitter<TopOverlayFeatureStates> emit,
  ) async {
    LoadingOverlayFeatureState(_currentState);
    _currentState.initController(
      VideoPlayerController.networkUrl(
        Uri.parse(event.videoUrl),
      ),
    );
    await _currentState.playerController?.initialize();
    await _currentState.playerController?.play();
    emit(LoadedOverlayFeatureState(_currentState));
  }
}
