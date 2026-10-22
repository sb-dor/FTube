import 'package:shared_preferences/shared_preferences.dart';

abstract interface class IPreviewHintRepository {
  /// Whether the user has already seen the hold-to-preview hint.
  bool isShown();

  /// Remembers that the hint was shown so it never appears again.
  Future<void> markShown();
}

final class PreviewHintRepositoryImpl implements IPreviewHintRepository {
  PreviewHintRepositoryImpl({required this._sharedPreferences});

  static const shownKey = 'preview_hint_shown';

  final SharedPreferences _sharedPreferences;

  @override
  bool isShown() => _sharedPreferences.getBool(shownKey) ?? false;

  @override
  Future<void> markShown() => _sharedPreferences.setBool(shownKey, true);
}
