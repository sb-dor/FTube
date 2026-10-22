import 'package:flutter/foundation.dart';

/// One place a stream can be downloaded from. YouTube serves the same stream (itag) through
/// several clients; each has its own URL and request rules.
@immutable
final class StreamSource {
  const StreamSource({
    required this.url,
    required this.client,
    this.headers = const {},
    this.useRangeHeader = false,
    this.chunkSize = 4 * 1024 * 1024,
    this.maxConnections = 6,
  });

  final Uri url;

  /// YouTube client the URL was issued to, e.g. `ANDROID_VR`.
  final String client;

  /// Headers every request must carry (the issuing client's user agent).
  final Map<String, String> headers;

  /// Ask for byte ranges with a `Range` header instead of the `range` query parameter.
  final bool useRangeHeader;

  /// Largest range requested at once.
  final int chunkSize;

  /// Parallel requests this source tolerates.
  final int maxConnections;
}

/// What a stream contains.
enum MediaStreamKind {
  audio,
  video,

  /// Video and sound in one file.
  muxed,
}

/// A downloadable stream of a video, with every source it is available from.
@immutable
final class MediaStream {
  const MediaStream({
    required this.itag,
    required this.kind,
    required this.container,
    required this.sizeBytes,
    required this.bitrate,
    required this.sources,
    this.codecs = '',
    this.qualityLabel,
    this.height = 0,
    this.fps = 0,
    this.isOriginalAudio = true,
    this.isDrcAudio = false,
  });

  final int itag;
  final MediaStreamKind kind;

  /// `mp4` or `webm`.
  final String container;
  final String codecs;
  final int sizeBytes;

  /// Bits per second.
  final int bitrate;

  /// `720p`, `1080p60`…; null for audio.
  final String? qualityLabel;
  final int height;
  final int fps;

  /// The video's own language (not a dubbed track).
  final bool isOriginalAudio;

  /// Dynamic-range-compressed copy of the audio.
  final bool isDrcAudio;

  /// Best first.
  final List<StreamSource> sources;

  bool get isH264 => codecs.startsWith('avc1');

  MediaStream withSources(List<StreamSource> sources) => MediaStream(
    itag: itag,
    kind: kind,
    container: container,
    sizeBytes: sizeBytes,
    bitrate: bitrate,
    sources: sources,
    codecs: codecs,
    qualityLabel: qualityLabel,
    height: height,
    fps: fps,
    isOriginalAudio: isOriginalAudio,
    isDrcAudio: isDrcAudio,
  );
}

/// All streams of one video.
@immutable
final class StreamCatalog {
  const StreamCatalog({required this.videoId, required this.streams});

  final String videoId;
  final List<MediaStream> streams;

  Iterable<MediaStream> of(MediaStreamKind kind) => streams.where((s) => s.kind == kind);
}
