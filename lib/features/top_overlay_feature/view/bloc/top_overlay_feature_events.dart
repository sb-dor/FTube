import 'package:flutter/foundation.dart';

@immutable
class TopOverlayFeatureEvents {}

class InitOverlayVideoController extends TopOverlayFeatureEvents {
  final String videoUrl;

  InitOverlayVideoController(this.videoUrl);
}

class ConvertToLoadingState extends TopOverlayFeatureEvents {}
