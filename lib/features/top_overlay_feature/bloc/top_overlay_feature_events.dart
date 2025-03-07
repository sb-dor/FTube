import 'package:flutter/foundation.dart';

@immutable
class TopOverlayFeatureEvents {}

class TopOverlayEmitterEvent extends TopOverlayFeatureEvents {}

class InitOverlayVideoController extends TopOverlayFeatureEvents {
  final String videoUrl;
  final Duration? position;

  InitOverlayVideoController(this.videoUrl, this.position);
}

class ConvertToLoadingState extends TopOverlayFeatureEvents {}

class PlayAndPauseVideoEvent extends TopOverlayFeatureEvents {}

class ShowAndHideButtonsOnClickEvent extends TopOverlayFeatureEvents {
  final bool refreshShowButtonTime;

  ShowAndHideButtonsOnClickEvent({this.refreshShowButtonTime = false});
}

class PlatControllerListenerEvent extends TopOverlayFeatureEvents {}
