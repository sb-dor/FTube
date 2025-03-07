import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_audio_info.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_video_info.dart';

sealed class VideoDownloadingStates {
  DownloadingVideoInfo? tempDownloadingVideoInfo;
  DownloadingAudioInfo? tempDownloadingAudioInfo;

  bool get isDownloading => tempDownloadingVideoInfo != null;

  VideoDownloadingStates({this.tempDownloadingVideoInfo, this.tempDownloadingAudioInfo});
}

final class VideoDownloadingGettingInfoState extends VideoDownloadingStates {
  VideoDownloadingGettingInfoState({
    super.tempDownloadingVideoInfo,
    super.tempDownloadingAudioInfo,
  });
}

final class VideoDownloadingLoadingState extends VideoDownloadingStates {
  VideoDownloadingLoadingState({super.tempDownloadingVideoInfo, super.tempDownloadingAudioInfo});
}

final class VideoDownloadingErrorState extends VideoDownloadingStates {
  VideoDownloadingErrorState({super.tempDownloadingVideoInfo, super.tempDownloadingAudioInfo});
}

final class VideoDownloadingGettingAudioInformationState extends VideoDownloadingStates {
  VideoDownloadingGettingAudioInformationState({
    super.tempDownloadingVideoInfo,
    super.tempDownloadingAudioInfo,
  });
}

final class VideoDownloadingAudioState extends VideoDownloadingStates {
  VideoDownloadingAudioState({super.tempDownloadingVideoInfo, super.tempDownloadingAudioInfo});
}

final class VideoDownloadingSavingOnStorageState extends VideoDownloadingStates {
  VideoDownloadingSavingOnStorageState({
    super.tempDownloadingVideoInfo,
    super.tempDownloadingAudioInfo,
  });
}

final class VideoDownloadingLoadedState extends VideoDownloadingStates {
  VideoDownloadingLoadedState({super.tempDownloadingVideoInfo, super.tempDownloadingAudioInfo});
}
