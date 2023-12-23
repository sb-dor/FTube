import 'package:youtube/pages/youtube_video_player_screen/domain/entities/downloading_video_info.dart';

abstract class VideoDownloadingStates {
  DownloadingVideoInfo? tempDownloadingVideoInfo;

  VideoDownloadingStates({this.tempDownloadingVideoInfo});
}

class VideoDownloadingGettingInfoState extends VideoDownloadingStates {
  VideoDownloadingGettingInfoState({DownloadingVideoInfo? tempDownloadingVideoInfo})
      : super(tempDownloadingVideoInfo: tempDownloadingVideoInfo);
}

class VideoDownloadingLoadingState extends VideoDownloadingStates {
  VideoDownloadingLoadingState({DownloadingVideoInfo? tempDownloadingVideoInfo})
      : super(tempDownloadingVideoInfo: tempDownloadingVideoInfo);
}

class VideoDownloadingErrorState extends VideoDownloadingStates {
  VideoDownloadingErrorState({DownloadingVideoInfo? tempDownloadingVideoInfo})
      : super(tempDownloadingVideoInfo: tempDownloadingVideoInfo);
}

class VideoDownloadingLoadedState extends VideoDownloadingStates {
  VideoDownloadingLoadedState({DownloadingVideoInfo? tempDownloadingVideoInfo})
      : super(tempDownloadingVideoInfo: tempDownloadingVideoInfo);
}
