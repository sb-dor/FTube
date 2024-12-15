import 'package:video_player/video_player.dart';

class TopOverlayFeatureStateModel {
  VideoPlayerController? _playerController;

  bool _isPlaying = true;

  bool get isPlaying => _isPlaying;

  VideoPlayerController? get playerController => _playerController;

  void initController(VideoPlayerController? controller) {
    _playerController = controller;
  }

  void setValueToPlaying(bool value) => _isPlaying = value;

  Future<void> disposeController() async {
    await _playerController?.dispose();
    _playerController = null;
  }
}
