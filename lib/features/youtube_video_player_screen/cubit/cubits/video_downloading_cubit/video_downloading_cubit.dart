import 'package:flutter_bloc/flutter_bloc.dart';

import 'video_downloading_states.dart';

class VideoDownloadingCubit extends Cubit<VideoDownloadingStates> {
  VideoDownloadingCubit() : super(VideoDownloadingLoadedState());

  void videoDownloadingGettingInfoState() => emit(VideoDownloadingGettingInfoState(
        tempDownloadingVideoInfo: state.tempDownloadingVideoInfo,
        tempDownloadingAudioInfo: state.tempDownloadingAudioInfo,
      ));

  void videoDownloadingLoadingState() => emit(VideoDownloadingLoadingState(
        tempDownloadingVideoInfo: state.tempDownloadingVideoInfo,
        tempDownloadingAudioInfo: state.tempDownloadingAudioInfo,
      ));

  void videoDownloadingErrorState() => emit(VideoDownloadingErrorState(
        tempDownloadingVideoInfo: state.tempDownloadingVideoInfo,
        tempDownloadingAudioInfo: state.tempDownloadingAudioInfo,
      ));

  void videoDownloadingGettingAudioInformationState() =>
      emit(VideoDownloadingGettingAudioInformationState(
        tempDownloadingVideoInfo: state.tempDownloadingVideoInfo,
        tempDownloadingAudioInfo: state.tempDownloadingAudioInfo,
      ));

  void videoDownloadingAudioState() => emit(VideoDownloadingAudioState(
        tempDownloadingVideoInfo: state.tempDownloadingVideoInfo,
        tempDownloadingAudioInfo: state.tempDownloadingAudioInfo,
      ));

  void videoDownloadingSavingOnStorageState() => emit(VideoDownloadingSavingOnStorageState(
        tempDownloadingVideoInfo: state.tempDownloadingVideoInfo,
        tempDownloadingAudioInfo: state.tempDownloadingAudioInfo,
      ));

  void videoDownloadingLoadedState() => emit(VideoDownloadingLoadedState(
        tempDownloadingVideoInfo: state.tempDownloadingVideoInfo,
        tempDownloadingAudioInfo: state.tempDownloadingAudioInfo,
      ));
}
