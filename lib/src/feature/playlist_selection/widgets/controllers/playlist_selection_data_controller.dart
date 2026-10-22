import 'package:flutter/foundation.dart';

/// The playlist ticked in the sheet (single choice; none means "in no playlist").
class PlaylistSelectionDataController with ChangeNotifier {
  int? _selectedId;
  bool _initialized = false;

  int? get selectedId => _selectedId;

  /// Pre-selects the playlist that holds the video; ignored after the first call or once the
  /// user picked something.
  void initialize(int? playlistId) {
    if (_initialized) return;
    _initialized = true;
    _selectedId = playlistId;
    notifyListeners();
  }

  /// Ticks [playlistId], or unticks it when it is already ticked.
  void toggle(int playlistId) {
    _initialized = true;
    _selectedId = _selectedId == playlistId ? null : playlistId;
    notifyListeners();
  }

  /// Ticks [playlistId].
  void select(int playlistId) {
    _initialized = true;
    if (_selectedId == playlistId) return;
    _selectedId = playlistId;
    notifyListeners();
  }
}
