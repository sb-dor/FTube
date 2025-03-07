import 'package:flutter/material.dart';
import 'package:youtube/features/top_overlay_feature/view/pages/top_overlay_feature.dart';

class TopOverlayLogic {
  static TopOverlayLogic? _instance;

  static TopOverlayLogic get instance =>
      _instance ??= TopOverlayLogic._internal();

  TopOverlayLogic._internal();

  OverlayEntry? _overlayEntry;

  // Method to show an overlay
  void showOverlay(BuildContext context, String videoId, Duration? position) {
    if (videoId.trim().isEmpty) return;

    removeOverlay();

    _overlayEntry = OverlayEntry(
      builder:
          (context) => TopOverlayFeature(
            overlayEntry: _overlayEntry!,
            videoId: videoId,
            position: position,
          ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Method to remove the overlay
  void removeOverlay() {
    if ((_overlayEntry?.mounted ?? false)) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }
}
