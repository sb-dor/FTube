import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';

abstract class AudioDownloadingStates {
  DownloadingAudioInfo? downloadingAudioInfo;

  bool get isAudioDownloading => downloadingAudioInfo != null;

  AudioDownloadingStates({this.downloadingAudioInfo});
}

class AudioGettingInformationState extends AudioDownloadingStates {
  AudioGettingInformationState({super.downloadingAudioInfo});
}

class AudioDownloadingState extends AudioDownloadingStates {
  AudioDownloadingState({super.downloadingAudioInfo});
}

class AudioDownloadingErrorState extends AudioDownloadingStates {
  AudioDownloadingErrorState({super.downloadingAudioInfo});
}

class AudioSavingOnStorageState extends AudioDownloadingStates {
  AudioSavingOnStorageState({super.downloadingAudioInfo});
}

class AudioDownloadingLoadedState extends AudioDownloadingStates {
  AudioDownloadingLoadedState({super.downloadingAudioInfo});
}
