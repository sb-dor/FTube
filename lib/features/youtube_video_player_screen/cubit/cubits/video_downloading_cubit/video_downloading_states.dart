import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_video_info.dart';

abstract class VideoDownloadingStates {
  DownloadingVideoInfo? tempDownloadingVideoInfo;
  DownloadingAudioInfo? tempDownloadingAudioInfo;

  bool get isDownloading => tempDownloadingAudioInfo != null || tempDownloadingVideoInfo != null;

  VideoDownloadingStates({
    this.tempDownloadingVideoInfo,
    this.tempDownloadingAudioInfo,
  });
}

class VideoDownloadingGettingInfoState extends VideoDownloadingStates {
  VideoDownloadingGettingInfoState(
      {DownloadingVideoInfo? tempDownloadingVideoInfo,
      DownloadingAudioInfo? tempDownloadingAudioInfo})
      : super(
          tempDownloadingVideoInfo: tempDownloadingVideoInfo,
          tempDownloadingAudioInfo: tempDownloadingAudioInfo,
        );
}

class VideoDownloadingLoadingState extends VideoDownloadingStates {
  VideoDownloadingLoadingState(
      {DownloadingVideoInfo? tempDownloadingVideoInfo,
      DownloadingAudioInfo? tempDownloadingAudioInfo})
      : super(
          tempDownloadingVideoInfo: tempDownloadingVideoInfo,
          tempDownloadingAudioInfo: tempDownloadingAudioInfo,
        );
}

class VideoDownloadingErrorState extends VideoDownloadingStates {
  VideoDownloadingErrorState(
      {DownloadingVideoInfo? tempDownloadingVideoInfo,
      DownloadingAudioInfo? tempDownloadingAudioInfo})
      : super(
          tempDownloadingVideoInfo: tempDownloadingVideoInfo,
          tempDownloadingAudioInfo: tempDownloadingAudioInfo,
        );
}

class VideoDownloadingGettingAudioInformationState extends VideoDownloadingStates {
  VideoDownloadingGettingAudioInformationState(
      {DownloadingVideoInfo? tempDownloadingVideoInfo,
      DownloadingAudioInfo? tempDownloadingAudioInfo})
      : super(
          tempDownloadingVideoInfo: tempDownloadingVideoInfo,
          tempDownloadingAudioInfo: tempDownloadingAudioInfo,
        );
}

class VideoDownloadingAudioState extends VideoDownloadingStates {
  VideoDownloadingAudioState(
      {DownloadingVideoInfo? tempDownloadingVideoInfo,
      DownloadingAudioInfo? tempDownloadingAudioInfo})
      : super(
          tempDownloadingVideoInfo: tempDownloadingVideoInfo,
          tempDownloadingAudioInfo: tempDownloadingAudioInfo,
        );
}

class VideoDownloadingSavingOnStorageState extends VideoDownloadingStates {
  VideoDownloadingSavingOnStorageState(
      {DownloadingVideoInfo? tempDownloadingVideoInfo,
      DownloadingAudioInfo? tempDownloadingAudioInfo})
      : super(
          tempDownloadingVideoInfo: tempDownloadingVideoInfo,
          tempDownloadingAudioInfo: tempDownloadingAudioInfo,
        );
}

class VideoDownloadingLoadedState extends VideoDownloadingStates {
  VideoDownloadingLoadedState(
      {DownloadingVideoInfo? tempDownloadingVideoInfo,
      DownloadingAudioInfo? tempDownloadingAudioInfo})
      : super(
          tempDownloadingVideoInfo: tempDownloadingVideoInfo,
          tempDownloadingAudioInfo: tempDownloadingAudioInfo,
        );
}
