import '../repositories/downloading_info.dart';

class DownloadingAudioInfo implements DownloadingInfo {
  @override
  double? downloadingProgress;

  @override
  String? urlId;

  DownloadingAudioInfo({required this.urlId, this.downloadingProgress = 0.0});

  DownloadingAudioInfo clone() =>
      DownloadingAudioInfo(urlId: urlId, downloadingProgress: downloadingProgress);
}
