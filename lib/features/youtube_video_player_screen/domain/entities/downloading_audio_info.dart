import '../repositories/downloading_info.dart';

class DownloadingAudioInfo implements DownloadingInfo {
  @override
  double? downloadingProgress;

  @override
  String? urlId;

  @override
  String? mainVideoId;

  DownloadingAudioInfo({
    required this.urlId,
    this.downloadingProgress = 0.0,
    this.mainVideoId,
  });

  DownloadingAudioInfo clone() => DownloadingAudioInfo(
        urlId: urlId,
        downloadingProgress: downloadingProgress,
        mainVideoId: mainVideoId,
      );
}
