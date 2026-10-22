import 'package:youtube/src/common/youtube/youtube_client.dart';

abstract interface class ISearchSuggestionsRepository {
  /// Completions for a partially typed [query].
  Future<List<String>> suggestions(String query);
}

final class SearchSuggestionsRepositoryImpl implements ISearchSuggestionsRepository {
  SearchSuggestionsRepositoryImpl({required this._youtubeClient});

  final YoutubeClient _youtubeClient;

  @override
  Future<List<String>> suggestions(String query) => _youtubeClient.suggestions(query);
}
