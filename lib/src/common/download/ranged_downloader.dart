import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:youtube/src/common/model/media_stream.dart';

/// Thrown when a download is cancelled through its [DownloadCancellation].
final class DownloadCancelledException implements Exception {
  const DownloadCancelledException();

  @override
  String toString() => 'Download cancelled';
}

/// Thrown when YouTube refuses a stream (HTTP 403). Some videos only serve the first part of
/// their audio-only streams without a token; callers fall back to another stream.
final class StreamForbiddenException implements Exception {
  const StreamForbiddenException(this.url);

  final Uri url;

  @override
  String toString() =>
      'Stream forbidden (403): itag ${url.queryParameters['itag']}, '
      'client ${url.queryParameters['c']}';
}

/// Cancels a running [RangedDownloader.download] or [MediaMuxer] job.
final class DownloadCancellation {
  final _callbacks = <void Function()>[];
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final callback in List.of(_callbacks)) {
      callback();
    }
    _callbacks.clear();
  }

  /// Runs [callback] on cancellation (immediately when already cancelled).
  void onCancel(void Function() callback) {
    if (_cancelled) {
      callback();
    } else {
      _callbacks.add(callback);
    }
  }

  /// Throws [DownloadCancelledException] when cancelled.
  void throwIfCancelled() {
    if (_cancelled) throw const DownloadCancelledException();
  }
}

/// Downloads a googlevideo stream into a file with parallel ranged requests.
///
/// A single plain GET of a YouTube stream is throttled to roughly playback speed; requesting
/// the file in byte ranges over several connections runs at full bandwidth. Each range is
/// written at its own offset, so nothing is buffered in memory, and failed requests are
/// retried. When a source answers 403 the download moves to the next [StreamSource] and
/// continues where it was.
final class RangedDownloader {
  RangedDownloader({
    required this._createClient,
    this._chunkSize = 4 * 1024 * 1024,
    this._connections = 6,
    this._retries = 4,
  });

  /// What media players send: no compression (Dart's default asks for gzip).
  static const _mediaHeaders = {'accept-encoding': 'identity', 'accept': '*/*'};

  final http.Client Function() _createClient;

  /// Bytes each worker takes at a time; requests are further split by the source's limit.
  final int _chunkSize;
  final int _connections;
  final int _retries;

  /// Downloads [totalBytes] into [target] from the first working of [sources], reporting the
  /// running byte count to [onProgress]. Throws [StreamForbiddenException] when every source
  /// refuses, and [DownloadCancelledException] when [cancellation] fires.
  Future<void> download({
    required List<StreamSource> sources,
    required int totalBytes,
    required File target,
    required DownloadCancellation cancellation,
    void Function(int receivedBytes)? onProgress,
  }) async {
    assert(sources.isNotEmpty, 'At least one source is required');
    cancellation.throwIfCancelled();
    await target.parent.create(recursive: true);
    final file = await target.open(mode: FileMode.write);
    final client = _createClient();
    cancellation.onCancel(client.close);
    var sourceIndex = 0;
    var nextOffset = 0;
    var received = 0;
    // RandomAccessFile allows one pending operation at a time; writes are chained.
    var writes = Future<void>.value();

    Future<void> write(int offset, List<int> bytes) => writes = writes.then((_) async {
      await file.setPosition(offset);
      await file.writeFrom(bytes);
    });

    /// Moves to the next source after [failed] was refused; false when there is none.
    bool switchSource(int failed) {
      if (sourceIndex != failed) return true;
      final next = sourceIndex + 1 < sources.length ? sources[sourceIndex + 1].client : 'none';
      l.w('Download | ${sources[failed].client} refused the stream; next: $next');
      if (sourceIndex + 1 >= sources.length) return false;
      sourceIndex++;
      return true;
    }

    /// Returns false when the source changed; the caller splits the range again for it.
    Future<bool> fetchRange(int from, int to) async {
      for (var attempt = 0; ;) {
        cancellation.throwIfCancelled();
        final index = sourceIndex;
        final source = sources[index];
        var offset = from;
        try {
          final request = source.useRangeHeader
              ? (http.Request('GET', source.url)..headers['range'] = 'bytes=$from-$to')
              : http.Request(
                  'GET',
                  source.url.replace(
                    queryParameters: {...source.url.queryParameters, 'range': '$from-$to'},
                  ),
                );
          request.headers
            ..addAll(_mediaHeaders)
            ..addAll(source.headers);
          final response = await client.send(request);
          if (response.statusCode == 403) {
            await response.stream.drain<void>();
            throw StreamForbiddenException(source.url);
          }
          if (response.statusCode != 200 && response.statusCode != 206) {
            throw HttpException('Stream responded ${response.statusCode}', uri: source.url);
          }
          await for (final bytes in response.stream) {
            await write(offset, bytes);
            offset += bytes.length;
            received += bytes.length;
            onProgress?.call(received);
          }
          if (offset != to + 1) {
            throw HttpException('Range ended at $offset instead of ${to + 1}', uri: source.url);
          }
          return true;
        } on Object catch (error) {
          // Roll back the bytes of the failed attempt so progress stays accurate.
          received -= offset - from;
          if (cancellation.isCancelled) throw const DownloadCancelledException();
          if (error is StreamForbiddenException) {
            if (!switchSource(index)) rethrow;
            return false;
          }
          if (++attempt > _retries) rethrow;
          await Future<void>.delayed(Duration(milliseconds: 500 * attempt));
        }
      }
    }

    /// Downloads one worker chunk in requests no larger than the active source allows.
    Future<void> fetchChunk(int from, int to) async {
      var position = from;
      while (position <= to) {
        final limit = sources[sourceIndex].chunkSize;
        final end = math.min(position + limit, to + 1) - 1;
        if (await fetchRange(position, end)) position = end + 1;
      }
    }

    Future<void> worker() async {
      while (nextOffset < totalBytes) {
        final from = nextOffset;
        final to = math.min(from + _chunkSize, totalBytes) - 1;
        nextOffset = to + 1;
        await fetchChunk(from, to);
      }
    }

    /// Last resort, like a media player: one open-ended request per source, read from start to
    /// end, resuming where it stopped. Some sources refuse ranges but serve playback reads.
    Future<void> progressive() async {
      await writes.catchError((Object _) {});
      received = 0;
      onProgress?.call(0);
      for (final source in sources) {
        var offset = 0;
        for (var attempt = 0; offset < totalBytes && attempt <= _retries; attempt++) {
          cancellation.throwIfCancelled();
          final request = http.Request('GET', source.url)
            ..headers.addAll(_mediaHeaders)
            ..headers.addAll(source.headers)
            ..headers['range'] = 'bytes=$offset-';
          final http.StreamedResponse response;
          try {
            response = await client.send(request);
          } on Object {
            if (cancellation.isCancelled) throw const DownloadCancelledException();
            continue;
          }
          if (response.statusCode == 403) {
            await response.stream.drain<void>();
            break;
          }
          try {
            await for (final bytes in response.stream) {
              await write(offset, bytes);
              offset += bytes.length;
              received = offset;
              onProgress?.call(received);
            }
          } on Object {
            if (cancellation.isCancelled) throw const DownloadCancelledException();
          }
        }
        if (offset >= totalBytes) return;
        l.w('Download | ${source.client}: progressive read stopped at $offset');
      }
      throw StreamForbiddenException(sources.last.url);
    }

    try {
      final connections = math.min(_connections, sources.first.maxConnections);
      final workers = math.max(1, math.min(connections, (totalBytes / _chunkSize).ceil()));
      try {
        await Future.wait([for (var i = 0; i < workers; i++) worker()], eagerError: true);
      } on StreamForbiddenException {
        await progressive();
      }
      await writes;
    } finally {
      client.close();
      await writes.catchError((Object _) {});
      await file.close();
    }
  }
}
