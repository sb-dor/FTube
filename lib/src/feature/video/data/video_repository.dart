import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/model/video_details.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/common/youtube/youtube_client.dart';
import 'package:youtube/src/common/youtube/youtube_streams_client.dart';
import 'package:youtube/src/feature/video/models/video_streams.dart';
import 'package:youtube/src/feature/video/models/video_streams_converter.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

abstract interface class IVideoRepository {
  /// Watch-page details with the first page of related videos.
  Future<VideoDetails> details(String videoId);

  /// The next page of related videos.
  Future<VideoPage> related(String continuation);

  /// Streams for playback.
  Future<VideoStreams> streams(String videoId);

  /// Moves [video] to the top of the watch history.
  Future<void> addToHistory(VideoItem video);
}

final class VideoRepositoryImpl implements IVideoRepository {
  VideoRepositoryImpl({
    required this._youtubeClient,
    required this._youtubeExplode,
    required this._streamsClient,
    required this._database,
    this._streamsConverter = const VideoStreamsConverter(),
  });

  final YoutubeClient _youtubeClient;
  final YoutubeExplode _youtubeExplode;
  final YoutubeStreamsClient _streamsClient;
  final AppDatabase _database;
  final VideoStreamsConverter _streamsConverter;

  @override
  Future<VideoDetails> details(String videoId) => _youtubeClient.videoDetails(videoId);

  @override
  Future<VideoPage> related(String continuation) => _youtubeClient.related(continuation);

  @override
  Future<VideoStreams> streams(String videoId) async {
    StreamCatalog? catalog;
    try {
      catalog = await _streamsClient.catalog(videoId);
    } on NoStreamsException {
      catalog = null;
    }
    if (catalog != null) {
      final streams = _streamsConverter.convert(catalog);
      if (streams.playable.isNotEmpty) return streams;
    }
    // Live streams have no muxed files; they play from the HLS manifest.
    final hls = await _youtubeExplode.videos.streams.getHttpLiveStreamUrl(VideoId(videoId));
    return VideoStreams(playable: const [], isLive: true, hlsUrl: Uri.parse(hls));
  }

  @override
  Future<void> addToHistory(VideoItem video) => _database.transaction(() async {
    await (_database.delete(_database.videoHistory)..where((t) => t.videoId.equals(video.id))).go();
    await _database.into(_database.videoHistory).insert(video.toHistoryCompanion());
  });
}
