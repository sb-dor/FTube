import 'package:youtube/features/youtube_video_player_screen/domain/entities/downloading_info.dart';

class DownloadingVideoInfo implements DownloadingInfo {
  @override
  String? urlId;

  @override
  double? downloadingProgress;

  @override
  String? mainVideoId;

  DownloadingVideoInfo({required this.urlId, this.downloadingProgress = 0.0, this.mainVideoId});

  DownloadingVideoInfo clone() => DownloadingVideoInfo(
    urlId: urlId,
    downloadingProgress: downloadingProgress,
    mainVideoId: mainVideoId,
  );
}
