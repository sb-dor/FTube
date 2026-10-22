import 'package:flutter/foundation.dart';

/// Player popup UI state: whether the video picture is shown, and the seek bar position while
/// the user drags it.
class DownloadPlayerDataController with ChangeNotifier {
  bool _isVideoVisible = true;
  Duration? _dragPosition;

  bool get isVideoVisible => _isVideoVisible;

  /// Where the seek bar thumb is while dragging; null otherwise.
  Duration? get dragPosition => _dragPosition;

  void toggleVideo() {
    _isVideoVisible = !_isVideoVisible;
    notifyListeners();
  }

  void drag(Duration position) {
    if (_dragPosition == position) return;
    _dragPosition = position;
    notifyListeners();
  }

  void endDrag() {
    if (_dragPosition == null) return;
    _dragPosition = null;
    notifyListeners();
  }
}
