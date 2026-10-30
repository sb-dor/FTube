import 'package:flutter/foundation.dart';
import 'package:youtube/src/feature/playlist_creation/models/playlist_creation_draft.dart';

/// Holds the [PlaylistCreationDraft] until it is saved and validates it.
class PlaylistCreationDataController with ChangeNotifier {
  /// Longest allowed playlist name.
  static const int maxLength = 25;

  PlaylistCreationDraft _draft = const PlaylistCreationDraft();

  PlaylistCreationDraft get draft => _draft;

  /// Whether the trimmed name is empty.
  bool get isEmpty => _draft.name.trim().isEmpty;

  /// Whether the empty-name error should be shown.
  bool get showEmptyError => _draft.submitted && isEmpty;

  void setName(String value) {
    if (_draft.name == value) return;
    _draft = _draft.copyWith(name: value);
    notifyListeners();
  }

  /// Marks a submit attempt; returns whether the name is valid.
  bool submit() {
    _draft = _draft.copyWith(submitted: true);
    notifyListeners();
    return !isEmpty;
  }
}
