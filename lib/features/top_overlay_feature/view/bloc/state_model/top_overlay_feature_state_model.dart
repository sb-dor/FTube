import 'package:video_player/video_player.dart';

class TopOverlayFeatureStateModel {
  VideoPlayerController? _playerController;

  VideoPlayerController? get playerController => _playerController;

  void initController(VideoPlayerController? controller) {
    _playerController = controller;
  }
}
