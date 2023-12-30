import 'package:youtube/pages/youtube_video_player_screen/domain/repositories/downloading_info.dart';

class DownloadingVideoInfo implements DownloadingInfo {
  @override
  String? urlId;
  @override
  double? downloadingProgress;

  DownloadingVideoInfo({required this.urlId, this.downloadingProgress = 0.0});

  DownloadingVideoInfo clone() => DownloadingVideoInfo(
        urlId: urlId,
        downloadingProgress: downloadingProgress,
      );
}
