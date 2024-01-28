import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';

abstract class AudioDownloadingStates {
  DownloadingAudioInfo? downloadingAudioInfo;

  AudioDownloadingStates({this.downloadingAudioInfo});
}

class AudioGettingInformationState extends AudioDownloadingStates {
  AudioGettingInformationState({DownloadingAudioInfo? downloadingAudioInfo})
      : super(downloadingAudioInfo: downloadingAudioInfo);
}

class AudioDownloadingState extends AudioDownloadingStates {
  AudioDownloadingState({DownloadingAudioInfo? downloadingAudioInfo})
      : super(downloadingAudioInfo: downloadingAudioInfo);
}

class AudioDownloadingErrorState extends AudioDownloadingStates {
  AudioDownloadingErrorState({DownloadingAudioInfo? downloadingAudioInfo})
      : super(downloadingAudioInfo: downloadingAudioInfo);
}

class AudioSavingOnStorageState extends AudioDownloadingStates {
  AudioSavingOnStorageState({DownloadingAudioInfo? downloadingAudioInfo})
      : super(downloadingAudioInfo: downloadingAudioInfo);
}

class AudioDownloadingLoadedState extends AudioDownloadingStates {
  AudioDownloadingLoadedState({DownloadingAudioInfo? downloadingAudioInfo})
      : super(downloadingAudioInfo: downloadingAudioInfo);
}
