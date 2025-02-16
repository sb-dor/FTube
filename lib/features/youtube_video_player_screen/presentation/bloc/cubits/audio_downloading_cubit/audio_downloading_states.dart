import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';

sealed class AudioDownloadingStates {
  DownloadingAudioInfo? downloadingAudioInfo;

  bool get isAudioDownloading => downloadingAudioInfo != null;

  AudioDownloadingStates({this.downloadingAudioInfo});
}

final class AudioGettingInformationState extends AudioDownloadingStates {
  AudioGettingInformationState({super.downloadingAudioInfo});
}

final class AudioDownloadingState extends AudioDownloadingStates {
  AudioDownloadingState({super.downloadingAudioInfo});
}

final class AudioDownloadingErrorState extends AudioDownloadingStates {
  AudioDownloadingErrorState({super.downloadingAudioInfo});
}

final class AudioSavingOnStorageState extends AudioDownloadingStates {
  AudioSavingOnStorageState({super.downloadingAudioInfo});
}

final class AudioDownloadingLoadedState extends AudioDownloadingStates {
  AudioDownloadingLoadedState({super.downloadingAudioInfo});
}
