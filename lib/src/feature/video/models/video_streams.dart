import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/model/media_stream.dart';

/// A playable stream with video and sound in one file.
@immutable
final class PlayableStream {
  const PlayableStream({required this.qualityLabel, required this.sources, required this.height});

  final String qualityLabel;

  /// Best first; the player moves to the next one when a source is refused.
  final List<StreamSource> sources;
  final int height;

  Uri get url => sources.first.url;
}

/// What the player needs for one video.
@immutable
final class VideoStreams {
  const VideoStreams({required this.playable, this.audio, this.isLive = false, this.hlsUrl});

  /// Muxed streams, lowest quality first.
  final List<PlayableStream> playable;

  /// Audio-only stream for background playback.
  final StreamSource? audio;

  /// Live streams play from [hlsUrl].
  final bool isLive;
  final Uri? hlsUrl;

  /// Stream to start with: the best muxed stream up to 360p, else the lowest one.
  PlayableStream? get initial {
    if (playable.isEmpty) return null;
    return playable.lastWhere((s) => s.height <= 360, orElse: () => playable.first);
  }
}
