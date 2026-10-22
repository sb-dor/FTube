import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/model/media_stream.dart';

/// What the user downloads.
enum DownloadKind {
  audio('sound'),
  video('video');

  const DownloadKind(this.analyticsName);

  /// Value of the `download_type` analytics parameter.
  final String analyticsName;
}

/// Where the finished file goes.
enum DownloadTarget {
  /// The app's own storage; listed under Library → In-App downloads.
  appStorage,

  /// The phone: the Gallery for videos, the public Downloads folder for audio.
  device,
}

/// One downloadable quality.
///
/// A video option either is a muxed stream (video and sound in one file, fast, at most 360p) or
/// pairs a video-only stream with the best audio stream, which are combined after downloading.
@immutable
final class DownloadOption {
  const DownloadOption.audio({required MediaStream this.audio, this.soundFallback})
    : kind = DownloadKind.audio,
      video = null,
      muxed = null,
      videoAlternatives = const [];

  const DownloadOption.video({
    required MediaStream this.video,
    required this.audio,
    this.soundFallback,
    this.videoAlternatives = const [],
  }) : kind = DownloadKind.video,
       muxed = null;

  const DownloadOption.muxed({required MediaStream this.muxed})
    : kind = DownloadKind.video,
      video = null,
      audio = null,
      soundFallback = null,
      videoAlternatives = const [];

  final DownloadKind kind;
  final MediaStream? video;
  final MediaStream? audio;
  final MediaStream? muxed;

  /// Stream with sound used when YouTube refuses [audio] from every source (it blocks the
  /// audio-only streams of some videos); its sound track is copied out with FFmpeg.
  final MediaStream? soundFallback;

  /// Other streams of the same quality (another codec), tried when YouTube refuses [video].
  final List<MediaStream> videoAlternatives;

  /// Muxed streams need no processing after download.
  bool get isFast => muxed != null;

  /// `720p`, `1080p60`… for videos.
  String? get qualityLabel => muxed?.qualityLabel ?? video?.qualityLabel;

  int get sizeBytes => (muxed?.sizeBytes ?? 0) + (video?.sizeBytes ?? 0) + (audio?.sizeBytes ?? 0);

  /// Audio bitrate for audio options, total bitrate otherwise.
  int get bitrateKbps => ((muxed ?? video ?? audio)?.bitrate ?? 0) ~/ 1000;

  /// File extension of the saved file.
  String get extension => switch (kind) {
    DownloadKind.audio => audio!.container == 'mp4' ? 'm4a' : audio!.container,
    DownloadKind.video => 'mp4',
  };

  /// Stable id of this option (stream tags).
  String get id => [muxed?.itag, video?.itag, audio?.itag].whereType<int>().join('+');

  @override
  bool operator ==(Object other) => other is DownloadOption && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// The qualities offered for one video.
@immutable
final class DownloadOptions {
  const DownloadOptions({required this.audio, required this.video});

  /// Best first; the first one is recommended.
  final List<DownloadOption> audio;

  /// Highest resolution first.
  final List<DownloadOption> video;

  List<DownloadOption> of(DownloadKind kind) => switch (kind) {
    DownloadKind.audio => audio,
    DownloadKind.video => video,
  };
}
