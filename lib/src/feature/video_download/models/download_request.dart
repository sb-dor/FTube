import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';

/// A download the user started.
@immutable
final class DownloadRequest {
  const DownloadRequest({required this.video, required this.option, required this.target});

  final VideoItem video;
  final DownloadOption option;
  final DownloadTarget target;
}

/// Stage of a running download.
enum DownloadPhase {
  /// Downloading the stream(s).
  downloading,

  /// Combining video and sound.
  processing,

  /// Moving the file to its destination.
  saving,
}

/// Progress of a running download.
@immutable
final class DownloadProgress {
  const DownloadProgress({required this.phase, this.receivedBytes = 0, this.totalBytes = 0});

  final DownloadPhase phase;
  final int receivedBytes;
  final int totalBytes;

  /// 0…1 while downloading; null when indeterminate.
  double? get fraction =>
      phase == DownloadPhase.downloading && totalBytes > 0 ? receivedBytes / totalBytes : null;
}
