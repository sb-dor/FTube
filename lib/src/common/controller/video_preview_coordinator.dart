import 'package:flutter/foundation.dart';

/// Makes sure only one card previews at a time, and lets other screens stop it.
class VideoPreviewCoordinator with ChangeNotifier {
  Object? _active;

  /// The owner whose preview may play.
  Object? get active => _active;

  /// [owner] starts previewing; any other preview stops.
  void claim(Object owner) {
    if (identical(_active, owner)) return;
    _active = owner;
    notifyListeners();
  }

  /// [owner] stopped on its own.
  void release(Object owner) {
    if (!identical(_active, owner)) return;
    _active = null;
    notifyListeners();
  }

  /// Stops whatever is previewing (e.g. a video screen opens).
  void stopAll() {
    if (_active == null) return;
    _active = null;
    notifyListeners();
  }
}
