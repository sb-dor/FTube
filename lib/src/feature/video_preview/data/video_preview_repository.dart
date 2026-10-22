import 'package:collection/collection.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/youtube/youtube_streams_client.dart';

abstract interface class IVideoPreviewRepository {
  /// The smallest MP4 stream with sound, for a quick muted preview; null when none.
  Future<StreamSource?> previewSource(String videoId);
}

final class VideoPreviewRepositoryImpl implements IVideoPreviewRepository {
  VideoPreviewRepositoryImpl({required this._streamsClient});

  final YoutubeStreamsClient _streamsClient;

  @override
  Future<StreamSource?> previewSource(String videoId) async {
    final catalog = await _streamsClient.catalog(videoId);
    return catalog
        .of(MediaStreamKind.muxed)
        .where((s) => s.container == 'mp4')
        .sorted((a, b) => a.sizeBytes.compareTo(b.sizeBytes))
        .firstOrNull
        ?.sources
        .first;
  }
}
