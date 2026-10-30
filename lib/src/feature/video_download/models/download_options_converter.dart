import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/youtube/youtube_streams_client.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';

/// Builds the quality lists offered for a video.
///
/// Audio: original-language tracks (the non-compressed copy before the DRC one), M4A (AAC)
/// preferred, best bitrate first.
/// Video: muxed streams first (fast, no processing), then one video-only stream per quality —
/// H.264 MP4 preferred — paired with the best M4A audio, highest resolution first.
final class DownloadOptionsConverter extends Converter<StreamCatalog, DownloadOptions> {
  const DownloadOptionsConverter();

  @override
  DownloadOptions convert(StreamCatalog input) {
    final audioStreams = input
        .of(MediaStreamKind.audio)
        .where((s) => s.isOriginalAudio)
        .sorted((a, b) {
          if (a.isDrcAudio != b.isDrcAudio) return a.isDrcAudio ? 1 : -1;
          return b.bitrate.compareTo(a.bitrate);
        })
        // One entry per bitrate class: the DRC copy only when there is no plain one.
        .fold<List<MediaStream>>([], (list, s) {
          final duplicate = list.any(
            (known) => known.container == s.container && (known.bitrate - s.bitrate).abs() < 16000,
          );
          return duplicate ? list : [...list, s];
        });
    final m4a = audioStreams.where((s) => s.container == 'mp4').toList();
    final offeredAudio = m4a.isNotEmpty ? m4a : audioStreams;
    final bestAudio = offeredAudio.firstOrNull;
    final soundFallback = input.bestMuxed;

    final muxed = input
        .of(MediaStreamKind.muxed)
        .where((s) => s.container == 'mp4')
        .sorted((a, b) => b.height.compareTo(a.height))
        .groupFoldBy<String, MediaStream>(
          (s) => s.qualityLabel ?? '${s.itag}',
          (previous, s) => previous ?? s,
        )
        .values;

    // Per quality: the most compatible stream, plus the other codecs as alternatives.
    final videoOnly = bestAudio == null && soundFallback == null
        ? const <(MediaStream, List<MediaStream>)>[]
        : input
              .of(MediaStreamKind.video)
              .groupListsBy((s) => s.qualityLabel ?? '${s.itag}')
              .values
              .map((group) {
                final best =
                    group.firstWhereOrNull((s) => s.container == 'mp4' && s.isH264) ??
                    group.firstWhereOrNull((s) => s.container == 'mp4') ??
                    group.first;
                return (
                  best,
                  [
                    for (final s in group)
                      if (s != best) s,
                  ],
                );
              })
              .sorted((a, b) {
                final byHeight = b.$1.height.compareTo(a.$1.height);
                return byHeight != 0 ? byHeight : b.$1.fps.compareTo(a.$1.fps);
              });

    return DownloadOptions(
      audio: [
        for (final stream in offeredAudio)
          DownloadOption.audio(audio: stream, soundFallback: soundFallback),
      ],
      video: [
        for (final stream in muxed) DownloadOption.muxed(muxed: stream),
        for (final (stream, alternatives) in videoOnly)
          DownloadOption.video(
            video: stream,
            audio: bestAudio ?? soundFallback,
            soundFallback: soundFallback,
            videoAlternatives: alternatives,
          ),
      ],
    );
  }
}
