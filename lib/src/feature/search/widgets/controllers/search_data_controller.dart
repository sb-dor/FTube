import 'package:flutter/foundation.dart';
import 'package:youtube/src/feature/search/models/search_filter.dart';

/// The submitted query, the active filter and whether results or the typing list is shown.
class SearchDataController with ChangeNotifier {
  String _query = '';
  SearchFilter _filter = const SearchFilter();
  bool _showResults = false;

  /// The last submitted query; empty before the first search.
  String get query => _query;

  SearchFilter get filter => _filter;

  /// True while results (or their loading/error state) are shown instead of suggestions.
  bool get showResults => _showResults;

  /// Shows results for [query].
  void submit(String query) {
    _query = query;
    _showResults = true;
    notifyListeners();
  }

  /// Switches to the suggestions/history list while the user edits the text.
  void edit() {
    if (!_showResults) return;
    _showResults = false;
    notifyListeners();
  }

  /// Goes back to the results of the last [query], if there is one; returns whether it did.
  bool backToResults() {
    if (_showResults || _query.isEmpty) return false;
    _showResults = true;
    notifyListeners();
    return true;
  }

  void setFilter(SearchFilter filter) {
    if (_filter == filter) return;
    _filter = filter;
    notifyListeners();
  }
}
