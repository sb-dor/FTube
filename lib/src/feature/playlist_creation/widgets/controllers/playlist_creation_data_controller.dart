import 'package:flutter/foundation.dart';

/// The new playlist's name as typed, and whether the user already tried to submit it.
class PlaylistCreationDataController with ChangeNotifier {
  /// Longest allowed playlist name.
  static const int maxLength = 25;

  String _name = '';
  bool _submitted = false;

  String get name => _name;

  /// Whether the trimmed name is empty.
  bool get isEmpty => _name.trim().isEmpty;

  /// Whether the empty-name error should be shown.
  bool get showEmptyError => _submitted && isEmpty;

  void setName(String value) {
    if (_name == value) return;
    _name = value;
    notifyListeners();
  }

  /// Marks a submit attempt; returns whether the name is valid.
  bool submit() {
    _submitted = true;
    notifyListeners();
    return !isEmpty;
  }
}
