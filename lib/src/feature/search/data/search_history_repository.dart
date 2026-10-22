import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ISearchHistoryRepository {
  /// Saved queries, newest first.
  Future<List<String>> read();

  /// Replaces the saved queries with [queries].
  Future<void> write(List<String> queries);
}

final class SearchHistoryRepositoryImpl implements ISearchHistoryRepository {
  SearchHistoryRepositoryImpl({required this._sharedPreferences});

  static const _key = 'search_history';

  final SharedPreferences _sharedPreferences;

  @override
  Future<List<String>> read() async => _sharedPreferences.getStringList(_key) ?? const [];

  @override
  Future<void> write(List<String> queries) async {
    final saved = await _sharedPreferences.setStringList(_key, queries);
    if (!saved) throw StateError('Search history was not saved');
  }
}
