import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/search/data/search_repository.dart';

part 'search_results_controller.freezed.dart';

@freezed
sealed class SearchResultsState with _$SearchResultsState {
  const SearchResultsState._();

  const factory SearchResultsState.initial() = SearchResults$InitialState;

  const factory SearchResultsState.inProgress() = SearchResults$InProgressState;

  const factory SearchResultsState.error({Object? error}) = SearchResults$ErrorState;

  /// [continuation] requests the next page; null when there is none.
  const factory SearchResultsState.completed({
    required List<VideoItem> videos,
    required String? continuation,
  }) = SearchResults$CompletedState;

  /// Whether another page can be requested.
  bool get hasMore => switch (this) {
    SearchResults$CompletedState(:final continuation) => continuation != null,
    _ => false,
  };
}

/// Runs a search and loads its next pages.
final class SearchResultsController extends StateController<SearchResultsState>
    with SequentialControllerHandler {
  SearchResultsController({
    required this._searchRepository,
    super.initialState = const SearchResultsState.initial(),
  });

  final ISearchRepository _searchRepository;

  void load({required String query, String? filter}) => handle(
    () async {
      setState(const SearchResultsState.inProgress());
      final page = await _searchRepository.videos(query: query, filter: filter);
      setState(SearchResultsState.completed(videos: page.videos, continuation: page.continuation));
    },
    error: (error, stackTrace) async => setState(SearchResultsState.error(error: error)),
    name: 'load',
  );

  void paginate({required String query, String? filter}) => handle(
    () async {
      final current = state;
      if (current is! SearchResults$CompletedState) return;
      final continuation = current.continuation;
      if (continuation == null) return;
      final page = await _searchRepository.videos(
        query: query,
        filter: filter,
        continuation: continuation,
      );
      final known = {for (final video in current.videos) video.id};
      setState(
        SearchResultsState.completed(
          videos: [...current.videos, ...page.videos.where((video) => !known.contains(video.id))],
          continuation: page.continuation,
        ),
      );
    },
    error: (error, stackTrace) async => setState(SearchResultsState.error(error: error)),
    name: 'paginate',
  );
}
