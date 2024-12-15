import 'package:flutter/foundation.dart';

@immutable
class TopOverlayFeatureEvents {}

class InitOverlayVideoController extends TopOverlayFeatureEvents {
  final String videoUrl;
  final Duration? position;

  InitOverlayVideoController(
    this.videoUrl,
    this.position,
  );
}

class DisposeOverlayVideoController extends TopOverlayFeatureEvents {}

class ConvertToLoadingState extends TopOverlayFeatureEvents {}

class PlayAndPauseVideoEvent extends TopOverlayFeatureEvents {}
