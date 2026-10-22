import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/common/youtube/youtube_client.dart';

abstract interface class ISearchRepository {
  /// A page of videos for [query] narrowed by the `sp` [filter]; pass the previous page's
  /// [continuation] for the next one.
  Future<VideoPage> videos({required String query, String? filter, String? continuation});
}

final class SearchRepositoryImpl implements ISearchRepository {
  SearchRepositoryImpl({required this._youtubeClient});

  final YoutubeClient _youtubeClient;

  @override
  Future<VideoPage> videos({required String query, String? filter, String? continuation}) =>
      _youtubeClient.search(query, filter: filter, continuation: continuation);
}
