import 'package:flutter/material.dart';
import 'package:youtube/features/top_overlay_feature/view/pages/top_overlay_feature.dart';

class TopOverlayLogic {
  static TopOverlayLogic? _instance;

  static TopOverlayLogic get instance => _instance ??= TopOverlayLogic._internal();

  TopOverlayLogic._internal();

  OverlayEntry? _overlayEntry;

  // Method to show an overlay
  void showOverlay(BuildContext context, String videoId) {
    if (_overlayEntry != null) {
      return; // Prevent multiple overlays
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => TopOverlayFeature(
        overlayEntry: _overlayEntry!,
        videoId: videoId,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  // Method to remove the overlay
  void removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
