import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/audio_downloading_cubit/audio_downloading_states.dart';

class AudioDownloadingCubit extends Cubit<AudioDownloadingStates> {
  AudioDownloadingCubit() : super(AudioDownloadingLoadedState());

  void audioGettingInformationState() => emit(AudioGettingInformationState(
        downloadingAudioInfo: state.downloadingAudioInfo,
      ));

  void audioDownloadingState() => emit(AudioDownloadingState(
        downloadingAudioInfo: state.downloadingAudioInfo,
      ));

  void audioDownloadingErrorState() => emit(AudioDownloadingErrorState(
        downloadingAudioInfo: state.downloadingAudioInfo,
      ));

  void audioSavingOnStorageState() => emit(AudioSavingOnStorageState(
        downloadingAudioInfo: state.downloadingAudioInfo,
      ));

  void audioDownloadingLoadedState() => emit(AudioDownloadingLoadedState(
        downloadingAudioInfo: state.downloadingAudioInfo,
      ));
}
