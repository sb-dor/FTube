import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:youtube/src/feature/video/models/video_streams.dart';

/// Player UI state: the chosen quality and whether the controls are on screen.
///
/// The controls hide again after 5 seconds of playback and stay while the video is paused.
class VideoPlaybackDataController with ChangeNotifier {
  PlayableStream? _quality;
  bool _controlsVisible = false;
  bool _isPlaying = false;
  Timer? _hideTimer;

  /// The quality playing or being opened; null for live streams.
  PlayableStream? get quality => _quality;

  bool get controlsVisible => _controlsVisible;

  void selectQuality(PlayableStream? quality) {
    if (identical(_quality, quality)) return;
    _quality = quality;
    notifyListeners();
  }

  /// The video started or stopped playing. Paused or finished: the controls stay on screen.
  void setPlaying(bool isPlaying) {
    if (_isPlaying == isPlaying) return;
    _isPlaying = isPlaying;
    if (isPlaying) return;
    _hideTimer?.cancel();
    _controlsVisible = true;
    notifyListeners();
  }

  void toggleControls() => _controlsVisible ? hideControls() : showControls();

  /// Shows the controls; they hide again after 5 seconds of playback.
  void showControls() {
    _hideTimer?.cancel();
    _controlsVisible = true;
    notifyListeners();
    _hideTimer = Timer(const Duration(seconds: 5), () {
      if (_isPlaying) hideControls();
    });
  }

  void hideControls() {
    _hideTimer?.cancel();
    _controlsVisible = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }
}
