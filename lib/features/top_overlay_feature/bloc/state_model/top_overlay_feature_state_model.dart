import 'dart:async';

import 'package:video_player/video_player.dart';

class TopOverlayFeatureStateModel {
  VideoPlayerController? _playerController;

  bool _isPlaying = true;

  bool get isPlaying => _isPlaying;

  VideoPlayerController? get playerController => _playerController;

  bool _showButtons = false;

  bool get showButtons => _showButtons;

  Timer? _timerForShowingButtons;

  Future<void> changeShowButtons(
    void Function() emitter, {
    bool refreshShowButtonTime = false,
  }) async {
    if (!_showButtons || refreshShowButtonTime) {
      _showButtons = true;
      emitter();

      if ((_timerForShowingButtons?.isActive ?? false)) {
        _timerForShowingButtons?.cancel();
      }

      // Use Future.delayed for the timer-like functionality
      try {
        _timerForShowingButtons = Timer(const Duration(seconds: 3), () {
          _showButtons = false;
          emitter();
        });
      } catch (_) {
        // Handle cancellation or errors if needed
      }
    } else {
      _showButtons = false;
      _timerForShowingButtons?.cancel();
      emitter();
    }
  }

  void initController(VideoPlayerController? controller) {
    _playerController = controller;
  }

  void setValueToPlaying(bool value) => _isPlaying = value;

  Future<void> disposeController() async {
    await _playerController?.dispose();
    _playerController = null;
  }
}
