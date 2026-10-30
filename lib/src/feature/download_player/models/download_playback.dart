import 'package:flutter/foundation.dart';

/// Where playback of the open file is.
@immutable
class DownloadPlayback {
  const DownloadPlayback({required this.position, required this.duration, required this.isPlaying});

  static const empty = DownloadPlayback(
    position: Duration.zero,
    duration: Duration.zero,
    isPlaying: false,
  );

  final Duration position;
  final Duration duration;
  final bool isPlaying;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadPlayback &&
          other.position == position &&
          other.duration == duration &&
          other.isPlaying == isPlaying;

  @override
  int get hashCode => Object.hash(position, duration, isPlaying);

  @override
  String toString() => 'DownloadPlayback($position / $duration, playing: $isPlaying)';
}
