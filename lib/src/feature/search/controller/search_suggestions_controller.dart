import 'dart:async';

import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/search/data/search_suggestions_repository.dart';

part 'search_suggestions_controller.freezed.dart';

@freezed
sealed class SearchSuggestionsState with _$SearchSuggestionsState {
  const SearchSuggestionsState._();

  /// Nothing requested, or the field was cleared.
  const factory SearchSuggestionsState.initial() = SearchSuggestions$InitialState;

  /// Suggestions for [query]; empty when there are none or the request failed.
  const factory SearchSuggestionsState.completed({
    required String query,
    required List<String> suggestions,
  }) = SearchSuggestions$CompletedState;

  /// The suggestions to show.
  List<String> get items => switch (this) {
    SearchSuggestions$CompletedState(:final suggestions) => suggestions,
    SearchSuggestions$InitialState() => const <String>[],
  };
}

/// Fetches suggestions for the text being typed.
///
/// Requests are debounced, and only the latest one may change the state: a response for an
/// older keystroke that arrives late is dropped.
final class SearchSuggestionsController extends StateController<SearchSuggestionsState>
    with SequentialControllerHandler {
  SearchSuggestionsController({
    required this._suggestionsRepository,
    this._debounce = const Duration(milliseconds: 300),
    super.initialState = const SearchSuggestionsState.initial(),
  });

  final ISearchSuggestionsRepository _suggestionsRepository;
  final Duration _debounce;
  Timer? _timer;

  /// Number of the latest [request] or [clear]; older requests compare against it.
  int _latest = 0;

  /// Requests suggestions for [query] once typing pauses; supersedes earlier requests.
  void request(String query) {
    final text = query.trim();
    if (text.isEmpty) return clear();
    _timer?.cancel();
    final id = ++_latest;
    _timer = Timer(_debounce, () => _fetch(text, id));
  }

  /// Drops pending requests and clears the suggestions.
  void clear() {
    _timer?.cancel();
    _latest++;
    handle(() async => setState(const SearchSuggestionsState.initial()), name: 'clear');
  }

  void _fetch(String query, int id) => handle(
    () async {
      if (id != _latest) return;
      final suggestions = await _suggestionsRepository.suggestions(query);
      if (id != _latest) return;
      setState(SearchSuggestionsState.completed(query: query, suggestions: suggestions));
    },
    error: (error, stackTrace) async {
      if (id != _latest) return;
      setState(SearchSuggestionsState.completed(query: query, suggestions: const []));
    },
    name: 'fetch',
  );

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
