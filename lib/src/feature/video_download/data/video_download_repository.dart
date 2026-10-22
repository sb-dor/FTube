import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:l/l.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/download/media_muxer.dart';
import 'package:youtube/src/common/download/ranged_downloader.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/utils/duration_format.dart';
import 'package:youtube/src/common/utils/file_name.dart';
import 'package:youtube/src/common/youtube/youtube_streams_client.dart';
import 'package:youtube/src/feature/video_download/data/device_media_store.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';
import 'package:youtube/src/feature/video_download/models/download_request.dart';

abstract interface class IVideoDownloadRepository {
  /// Audio and video qualities available for [videoId].
  Future<DownloadOptions> options(String videoId);

  /// Runs [request]; emits progress and completes when the file is saved. Cancelling the
  /// subscription stops the download and removes temporary files.
  Stream<DownloadProgress> download(DownloadRequest request);
}

final class VideoDownloadRepositoryImpl implements IVideoDownloadRepository {
  VideoDownloadRepositoryImpl({
    required this._streamsClient,
    required this._downloader,
    required this._muxer,
    required this._mediaStore,
    required this._database,
    required this._temporaryDirectory,
  });

  final YoutubeStreamsClient _streamsClient;
  final RangedDownloader _downloader;
  final IMediaMuxer _muxer;
  final IDeviceMediaStore _mediaStore;
  final AppDatabase _database;
  final Future<Directory> Function() _temporaryDirectory;

  @override
  Future<DownloadOptions> options(String videoId) async {
    return buildDownloadOptions(await _streamsClient.catalog(videoId));
  }

  @override
  Stream<DownloadProgress> download(DownloadRequest request) {
    final controller = StreamController<DownloadProgress>();
    final cancellation = DownloadCancellation();
    controller.onCancel = cancellation.cancel;
    Future<void>(() async {
      final temporary = <File>[];
      try {
        await _run(request, cancellation, temporary, controller.add);
      } on Object catch (error, stackTrace) {
        if (!cancellation.isCancelled) controller.addError(error, stackTrace);
      } finally {
        for (final file in temporary) {
          if (file.existsSync()) await file.delete().catchError((Object _) => file);
        }
        await controller.close();
      }
    }).ignore();
    return controller.stream;
  }

  Future<void> _run(
    DownloadRequest request,
    DownloadCancellation cancellation,
    List<File> temporary,
    void Function(DownloadProgress) emit,
  ) async {
    final option = request.option;
    final videoId = request.video.id;
    final workDir = await Directory('${(await _temporaryDirectory()).path}/ftube_downloads')
        .create(recursive: true);
    File partFile(MediaStream stream) {
      final file = File('${workDir.path}/${videoId}_${stream.itag}.${stream.container}');
      temporary.add(file);
      return file;
    }

    // Combined progress over every stream being downloaded.
    final totals = <int, int>{};
    final received = <int, int>{};
    var lastEmit = DateTime.fromMillisecondsSinceEpoch(0);
    void report({bool force = false}) {
      final now = DateTime.now();
      if (!force && now.difference(lastEmit) < const Duration(milliseconds: 200)) return;
      lastEmit = now;
      emit(
        DownloadProgress(
          phase: DownloadPhase.downloading,
          receivedBytes: received.values.sum,
          totalBytes: totals.values.sum,
        ),
      );
    }

    final streamsCancellation = DownloadCancellation();
    cancellation.onCancel(streamsCancellation.cancel);
    Future<File> fetch(MediaStream stream, {required int slot}) async {
      final file = partFile(stream);
      totals[slot] = stream.sizeBytes;
      l.d('Download | itag ${stream.itag} from ${stream.sources.map((s) => s.client).join(' > ')}');
      received[slot] = 0;
      report(force: true);
      await _downloader.download(
        sources: stream.sources,
        totalBytes: stream.sizeBytes,
        target: file,
        cancellation: streamsCancellation,
        onProgress: (bytes) {
          received[slot] = bytes;
          report();
        },
      );
      return file;
    }

    // Video: the chosen stream, or another codec of the same quality when it is refused.
    Future<File> fetchVideo(MediaStream video) async {
      final candidates = [video, ...option.videoAlternatives];
      for (var i = 0; ; i++) {
        try {
          return await fetch(candidates[i], slot: 0);
        } on StreamForbiddenException {
          if (i == candidates.length - 1) rethrow;
        }
      }
    }

    // Sound: the audio stream, or the fallback stream with sound when YouTube refuses it.
    var soundFromFallback = false;
    Future<File?> fetchSound() async {
      final audio = option.audio;
      if (audio == null) return null;
      try {
        return await fetch(audio, slot: 1);
      } on StreamForbiddenException {
        final fallback = option.soundFallback;
        if (fallback == null) rethrow;
        soundFromFallback = true;
        return fetch(fallback, slot: 1);
      }
    }

    // When one stream fails the others stop too, and the first error is reported as is.
    late final List<File?> parts;
    try {
      parts = await Future.wait<File?>([
        if (option.video case final video?) fetchVideo(video) else Future.value(),
        fetchSound(),
        if (option.muxed case final muxed?) fetch(muxed, slot: 2) else Future.value(),
      ], eagerError: true);
    } on Object {
      streamsCancellation.cancel();
      rethrow;
    }
    final [videoPart, soundPart, muxedPart] = parts;
    report(force: true);

    // Build the final file.
    File result;
    var extension = option.extension;
    if (muxedPart != null) {
      result = muxedPart;
    } else if (videoPart != null && soundPart != null) {
      emit(const DownloadProgress(phase: DownloadPhase.processing));
      result = File('${workDir.path}/${videoId}_${option.id}.mp4');
      temporary.add(result);
      await _muxer.mux(
        video: videoPart,
        audio: soundPart,
        output: result,
        cancellation: cancellation,
      );
    } else if (soundPart != null && soundFromFallback) {
      emit(const DownloadProgress(phase: DownloadPhase.processing));
      extension = 'm4a';
      result = File('${workDir.path}/${videoId}_${option.id}_sound.m4a');
      temporary.add(result);
      await _muxer.extractAudio(input: soundPart, output: result, cancellation: cancellation);
    } else {
      result = soundPart!;
    }

    cancellation.throwIfCancelled();
    emit(const DownloadProgress(phase: DownloadPhase.saving));
    final fileName = '${safeFileName(request.video.title)}.$extension';
    switch (request.target) {
      case DownloadTarget.device:
        // Gallery and Downloads show the file name, so stage it under the video title.
        final named = await result.copy('${workDir.path}/$fileName');
        temporary.add(named);
        if (option.kind == DownloadKind.video) {
          await _mediaStore.saveVideoToGallery(named);
        } else {
          await _mediaStore.saveToDownloads(named, fileName);
        }
      case DownloadTarget.appStorage:
        final directory = await _mediaStore.appDownloadsDirectory();
        final saved = await result.copy(_uniquePath(directory, fileName));
        await _database
            .into(_database.fileDownloads)
            .insert(
              FileDownloadsCompanion.insert(
                name: Value(request.video.title),
                downloadedPath: Value(saved.path),
                imagePath: Value(request.video.thumbnail),
                views: Value(request.video.viewsText),
                createdAt: Value(DateTime.now().toString().substring(0, 16)),
                channelName: Value(request.video.channelName),
                videoId: Value(videoId),
                mediaType: Value(option.kind.name),
                durationSeconds: Value(secondsFromDurationText(request.video.durationText)),
              ),
            );
    }
  }

  String _uniquePath(Directory directory, String fileName) {
    final dot = fileName.lastIndexOf('.');
    final base = fileName.substring(0, dot);
    final extension = fileName.substring(dot);
    var candidate = '${directory.path}/$fileName';
    for (var n = 2; File(candidate).existsSync(); n++) {
      candidate = '${directory.path}/$base ($n)$extension';
    }
    return candidate;
  }
}

/// Builds the quality lists offered for a video.
///
/// Audio: original-language tracks (the non-compressed copy before the DRC one), M4A (AAC)
/// preferred, best bitrate first.
/// Video: muxed streams first (fast, no processing), then one video-only stream per quality —
/// H.264 MP4 preferred — paired with the best M4A audio, highest resolution first.
DownloadOptions buildDownloadOptions(StreamCatalog catalog) {
  final audioStreams = catalog
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
  final soundFallback = catalog.bestMuxed;

  final muxed = catalog
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
      : catalog
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
