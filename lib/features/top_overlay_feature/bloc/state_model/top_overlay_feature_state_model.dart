import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class TopOverlayFeatureStateModel {
  VideoPlayerController? _playerController;

  bool _isPlaying = true;

  bool get isPlaying => _isPlaying;

  VideoPlayerController? get playerController => _playerController;

  bool _showButtons = false;

  bool get showButtons => _showButtons;

  Future<void> changeShowButtons(void Function() emitter) async {
    if (!_showButtons) {
      _showButtons = true;
      emitter();

      // Use Future.delayed for the timer-like functionality
      try {
        await Future.delayed(const Duration(seconds: 3));
        _showButtons = false;
        emitter();
      } catch (_) {
        // Handle cancellation or errors if needed
      }
    } else {
      _showButtons = false;
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
