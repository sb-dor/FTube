import 'dart:convert';

import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/youtube/json_node.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Converts a player-response `formats` / `adaptiveFormats` entry into a [MediaStream]; null
/// when the entry has no URL, itag, readable mime type or size.
final class FormatConverter extends Converter<JsonNode, MediaStream?> {
  const FormatConverter({
    required this.muxed,
    required this.durationMs,
    required this.source,
    this.url,
  });

  /// The entry comes from `formats` (video with sound), not `adaptiveFormats`.
  final bool muxed;

  /// Video length; estimates the size of entries without `contentLength`.
  final int? durationMs;

  /// Builds the download source for the stream URL.
  final StreamSource Function(Uri url) source;

  /// URL with solved challenges; replaces the entry's own `url`.
  final Uri? url;

  static final _mimeType = RegExp(r'^(\w+)/(\w+);\s*codecs="([^"]*)"');

  @override
  MediaStream? convert(JsonNode input) {
    final url = this.url ?? Uri.tryParse(input['url'].string ?? '');
    final itag = input['itag'].integer;
    final mime = input['mimeType'].string;
    if (url == null || itag == null || mime == null) return null;
    final match = _mimeType.firstMatch(mime);
    if (match == null) return null;
    final bitrate = input['bitrate'].integer ?? 0;
    final durationMs = this.durationMs;
    final size =
        input['contentLength'].integer ??
        (durationMs == null ? null : bitrate * durationMs ~/ 8000);
    if (size == null || size == 0) return null;
    final tags = _xtags(url);
    return MediaStream(
      itag: itag,
      kind: muxed
          ? MediaStreamKind.muxed
          : match.group(1) == 'audio'
          ? MediaStreamKind.audio
          : MediaStreamKind.video,
      container: match.group(2)!,
      codecs: match.group(3)!,
      sizeBytes: size,
      bitrate: bitrate,
      qualityLabel: input['qualityLabel'].string,
      height: input['height'].integer ?? 0,
      fps: input['fps'].integer ?? 0,
      isOriginalAudio: (tags['acont'] ?? 'original') == 'original',
      isDrcAudio: tags['drc'] == '1',
      sources: [source(url)],
    );
  }
}

/// Converts a youtube_explode [StreamInfo] (Android client) into a [MediaStream].
final class StreamInfoConverter extends Converter<StreamInfo, MediaStream> {
  const StreamInfoConverter({required this.userAgent});

  /// User agent the download requests carry.
  final String userAgent;

  @override
  MediaStream convert(StreamInfo input) {
    final client = input.url.queryParameters['c'] ?? '';
    // Android client URLs refuse the range query parameter and large ranges.
    final android = client == 'ANDROID';
    final tags = _xtags(input.url);
    return MediaStream(
      itag: input.tag,
      kind: switch (input) {
        MuxedStreamInfo() => MediaStreamKind.muxed,
        AudioOnlyStreamInfo() => MediaStreamKind.audio,
        _ => MediaStreamKind.video,
      },
      container: input.container.name,
      codecs: switch (input) {
        final VideoStreamInfo video => video.videoCodec,
        final AudioStreamInfo audio => audio.audioCodec,
        _ => '',
      },
      sizeBytes: input.size.totalBytes,
      bitrate: input.bitrate.bitsPerSecond,
      qualityLabel: input is VideoStreamInfo ? input.qualityLabel : null,
      height: input is VideoStreamInfo ? input.videoResolution.height : 0,
      fps: input is VideoStreamInfo ? input.framerate.framesPerSecond.round() : 0,
      isOriginalAudio:
          (tags['acont'] ?? 'original') == 'original' &&
          switch (input) {
            final AudioOnlyStreamInfo audio => audio.audioTrack?.audioIsDefault ?? true,
            _ => true,
          },
      isDrcAudio: tags['drc'] == '1',
      sources: [
        StreamSource(
          url: input.url,
          client: client,
          headers: {'user-agent': userAgent},
          useRangeHeader: android,
          chunkSize: android ? 1024 * 1024 : 4 * 1024 * 1024,
        ),
      ],
    );
  }
}

/// `xtags=acont=original:drc=1:lang=en` → `{acont: original, drc: 1, lang: en}`.
Map<String, String> _xtags(Uri url) => {
  for (final part in (url.queryParameters['xtags'] ?? '').split(':'))
    if (part.split('=') case [final key, final value]) key: value,
};
