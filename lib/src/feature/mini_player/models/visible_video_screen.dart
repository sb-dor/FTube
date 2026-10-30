import 'package:flutter/foundation.dart';

/// The full video screen on display, registered with the mini player scope so that a video
/// opened meanwhile (e.g. from a link) replaces it instead of stacking a second screen.
@immutable
final class VisibleVideoScreen {
  const VisibleVideoScreen({required this.videoId, required this.closeForReplacement});

  final String videoId;

  /// Closes the screen, and any sheet over it, without moving its video to the mini player.
  final VoidCallback closeForReplacement;
}
