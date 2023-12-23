class DownloadingVideoInfo {
  String urlId;
  double downloadingProgress;

  DownloadingVideoInfo({required this.urlId, this.downloadingProgress = 0.0});

  DownloadingVideoInfo clone() => DownloadingVideoInfo(
        urlId: urlId,
        downloadingProgress: downloadingProgress,
      );
}
