import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:youtube/src/common/download/ranged_downloader.dart';

/// Thrown when FFmpeg fails to combine streams.
final class MediaMuxException implements Exception {
  const MediaMuxException(this.logs);

  final String? logs;

  @override
  String toString() => 'FFmpeg could not combine the streams';
}

/// Combines a video-only and an audio-only stream into one MP4 without re-encoding.
abstract interface class IMediaMuxer {
  /// Video track of [video] plus the first audio track of [audio] into [output].
  Future<void> mux({
    required File video,
    required File audio,
    required File output,
    required DownloadCancellation cancellation,
  });

  /// Copies the audio track of [input] into [output] (e.g. `.m4a`).
  Future<void> extractAudio({
    required File input,
    required File output,
    required DownloadCancellation cancellation,
  });
}

/// [IMediaMuxer] backed by FFmpegKit.
final class FfmpegMediaMuxer implements IMediaMuxer {
  const FfmpegMediaMuxer();

  @override
  Future<void> extractAudio({
    required File input,
    required File output,
    required DownloadCancellation cancellation,
  }) => _run(
    ['-y', '-i', input.path, '-vn', '-map', '0:a:0', '-c', 'copy', output.path],
    output,
    cancellation,
  );

  @override
  Future<void> mux({
    required File video,
    required File audio,
    required File output,
    required DownloadCancellation cancellation,
  }) => _run(
    [
      '-y',
      '-i',
      video.path,
      '-i',
      audio.path,
      '-map',
      '0:v:0',
      '-map',
      '1:a:0',
      '-c',
      'copy',
      output.path,
    ],
    output,
    cancellation,
  );

  Future<void> _run(List<String> arguments, File output, DownloadCancellation cancellation) async {
    cancellation.throwIfCancelled();
    if (output.existsSync()) await output.delete();
    final completed = Completer<void>();
    final session = await FFmpegKit.executeWithArgumentsAsync(
      arguments,
      (_) => completed.complete(),
    );
    cancellation.onCancel(() => FFmpegKit.cancel(session.getSessionId()));
    await completed.future;
    final code = await session.getReturnCode();
    if (cancellation.isCancelled || ReturnCode.isCancel(code)) {
      throw const DownloadCancelledException();
    }
    if (!ReturnCode.isSuccess(code)) {
      throw MediaMuxException(await session.getAllLogsAsString());
    }
  }
}
