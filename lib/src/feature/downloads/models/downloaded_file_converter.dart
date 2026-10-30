import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/utils/youtube_link.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

/// Builds a [DownloadedFile] from its database row.
final class DownloadedFileConverter {
  const DownloadedFileConverter();

  /// [locatedPath] is where the file was found on this device; null when it is gone.
  DownloadedFile convert(FileDownloadRow row, {required String? locatedPath}) {
    final stored = row.downloadedPath ?? '';
    final videoId = row.videoId;
    return DownloadedFile(
      id: row.id,
      title: row.name ?? '',
      path: locatedPath ?? stored,
      storedPath: row.downloadedPath,
      mediaType: DownloadMediaType.resolve(row.mediaType, stored),
      exists: locatedPath != null,
      thumbnailUrl:
          row.imagePath ?? (videoId == null || videoId.isEmpty ? null : videoThumbnailUrl(videoId)),
      channelName: row.channelName,
      viewsText: row.views,
      videoId: videoId,
      duration: switch (row.durationSeconds) {
        final seconds? => Duration(seconds: seconds),
        null => null,
      },
      createdAt: row.createdAt,
    );
  }
}
