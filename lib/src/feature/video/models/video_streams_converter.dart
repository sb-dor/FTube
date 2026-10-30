import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/feature/video/models/video_streams.dart';

/// Picks what the player needs out of a [StreamCatalog]: the MP4 streams with video and sound,
/// lowest quality first, and the best original-language MP4 audio for background playback.
///
/// Live streams have no muxed files, so their [VideoStreams.playable] is empty.
final class VideoStreamsConverter extends Converter<StreamCatalog, VideoStreams> {
  const VideoStreamsConverter();

  @override
  VideoStreams convert(StreamCatalog input) {
    final playable = input
        .of(MediaStreamKind.muxed)
        .where((s) => s.container == 'mp4')
        .sorted((a, b) => a.height.compareTo(b.height))
        .map(
          (s) => PlayableStream(
            qualityLabel: s.qualityLabel ?? '${s.height}p',
            sources: s.sources,
            height: s.height,
          ),
        )
        .toList();
    // Full dynamic range first, then the highest bitrate.
    final audio = input
        .of(MediaStreamKind.audio)
        .where((s) => s.container == 'mp4' && s.isOriginalAudio)
        .sorted((a, b) {
          if (a.isDrcAudio != b.isDrcAudio) return a.isDrcAudio ? 1 : -1;
          return b.bitrate.compareTo(a.bitrate);
        })
        .firstOrNull;
    return VideoStreams(playable: playable, audio: audio?.sources.first);
  }
}
