import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_video_info.dart';

abstract class VideoDownloadingStates {
  DownloadingVideoInfo? tempDownloadingVideoInfo;
  DownloadingAudioInfo? tempDownloadingAudioInfo;

  bool get isDownloading => tempDownloadingVideoInfo != null;

  VideoDownloadingStates({
    this.tempDownloadingVideoInfo,
    this.tempDownloadingAudioInfo,
  });
}

class VideoDownloadingGettingInfoState extends VideoDownloadingStates {
  VideoDownloadingGettingInfoState(
      {super.tempDownloadingVideoInfo,
      super.tempDownloadingAudioInfo,});
}

class VideoDownloadingLoadingState extends VideoDownloadingStates {
  VideoDownloadingLoadingState(
      {super.tempDownloadingVideoInfo,
      super.tempDownloadingAudioInfo,});
}

class VideoDownloadingErrorState extends VideoDownloadingStates {
  VideoDownloadingErrorState(
      {super.tempDownloadingVideoInfo,
      super.tempDownloadingAudioInfo,});
}

class VideoDownloadingGettingAudioInformationState extends VideoDownloadingStates {
  VideoDownloadingGettingAudioInformationState(
      {super.tempDownloadingVideoInfo,
      super.tempDownloadingAudioInfo,});
}

class VideoDownloadingAudioState extends VideoDownloadingStates {
  VideoDownloadingAudioState(
      {super.tempDownloadingVideoInfo,
      super.tempDownloadingAudioInfo,});
}

class VideoDownloadingSavingOnStorageState extends VideoDownloadingStates {
  VideoDownloadingSavingOnStorageState(
      {super.tempDownloadingVideoInfo,
      super.tempDownloadingAudioInfo,});
}

class VideoDownloadingLoadedState extends VideoDownloadingStates {
  VideoDownloadingLoadedState(
      {super.tempDownloadingVideoInfo,
      super.tempDownloadingAudioInfo,});
}
