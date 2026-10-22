import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/common/youtube/youtube_client.dart';

abstract interface class ITrendingRepository {
  /// A page of trending videos for [query] narrowed by the YouTube [filter]; pass the previous
  /// page's [continuation] for the next one.
  Future<VideoPage> videos({required String query, required String filter, String? continuation});
}

final class TrendingRepositoryImpl implements ITrendingRepository {
  TrendingRepositoryImpl({required this._youtubeClient});

  final YoutubeClient _youtubeClient;

  @override
  Future<VideoPage> videos({required String query, required String filter, String? continuation}) =>
      _youtubeClient.search(query, filter: filter, continuation: continuation);
}
