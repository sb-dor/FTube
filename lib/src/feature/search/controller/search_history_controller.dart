import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/search/data/search_history_repository.dart';

part 'search_history_controller.freezed.dart';

@freezed
sealed class SearchHistoryState with _$SearchHistoryState {
  const SearchHistoryState._();

  const factory SearchHistoryState.initial() = SearchHistory$InitialState;

  const factory SearchHistoryState.error({Object? error}) = SearchHistory$ErrorState;

  /// Saved [queries], newest first.
  const factory SearchHistoryState.completed({required List<String> queries}) =
      SearchHistory$CompletedState;

  /// The queries to show.
  List<String> get items => switch (this) {
    SearchHistory$CompletedState(:final queries) => queries,
    _ => const <String>[],
  };
}

/// Saved search queries: newest first, unique ignoring case, at most [maxEntries].
///
/// Loading, adding and removing share one sequential queue so every change starts from the
/// result of the previous one and none is lost or dropped.
final class SearchHistoryController extends StateController<SearchHistoryState>
    with SequentialControllerHandler {
  SearchHistoryController({
    required this._historyRepository,
    super.initialState = const SearchHistoryState.initial(),
  });

  static const maxEntries = 30;

  final ISearchHistoryRepository _historyRepository;

  void load() => handle(
    () async {
      final queries = await _historyRepository.read();
      setState(SearchHistoryState.completed(queries: queries));
    },
    error: (error, stackTrace) async => setState(SearchHistoryState.error(error: error)),
    name: 'load',
  );

  /// Moves [query] to the top, replacing an entry that differs only in case.
  void add(String query) => handle(() async {
    final text = query.trim();
    if (text.isEmpty) return;
    final key = text.toLowerCase();
    final current = await _historyRepository.read();
    final queries = [
      text,
      ...current.where((entry) => entry.toLowerCase() != key),
    ].take(maxEntries).toList();
    await _historyRepository.write(queries);
    setState(SearchHistoryState.completed(queries: queries));
  }, name: 'add');

  /// Deletes [query] (ignoring case).
  void remove(String query) => handle(() async {
    final key = query.trim().toLowerCase();
    final current = await _historyRepository.read();
    final queries = current.where((entry) => entry.toLowerCase() != key).toList();
    if (queries.length == current.length) return;
    await _historyRepository.write(queries);
    setState(SearchHistoryState.completed(queries: queries));
  }, name: 'remove');
}
