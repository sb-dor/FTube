import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/common/youtube/youtube_client.dart';

abstract interface class IFeedRepository {
  /// A page of feed videos for [query]; pass the previous page's [continuation] for the next.
  Future<VideoPage> videos({required String query, String? filter, String? continuation});
}

final class FeedRepositoryImpl implements IFeedRepository {
  FeedRepositoryImpl({required this._youtubeClient});

  final YoutubeClient _youtubeClient;

  @override
  Future<VideoPage> videos({required String query, String? filter, String? continuation}) =>
      _youtubeClient.search(query, filter: filter, continuation: continuation);
}
