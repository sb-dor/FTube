import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/download/media_muxer.dart';
import 'package:youtube/src/common/download/ranged_downloader.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/youtube/youtube_streams_client.dart';
import 'package:youtube/src/feature/video_download/data/device_media_store.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';
import 'package:youtube/src/feature/video_download/models/download_request.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

MediaStream _stream(MediaStreamKind kind, int itag, Uri url, int size) => MediaStream(
  itag: itag,
  kind: kind,
  container: 'mp4',
  sizeBytes: size,
  bitrate: 128000,
  sources: [StreamSource(url: url, client: 'TEST')],
);

/// Records calls and writes a marker file instead of running FFmpeg.
class _FakeMuxer implements IMediaMuxer {
  final calls = <String>[];

  @override
  Future<void> extractAudio({
    required File input,
    required File output,
    required DownloadCancellation cancellation,
  }) async {
    calls.add('extract ${input.lengthSync()}');
    await output.writeAsString('audio-from-muxed');
  }

  @override
  Future<void> mux({
    required File video,
    required File audio,
    required File output,
    required DownloadCancellation cancellation,
  }) async {
    calls.add('mux');
    await output.writeAsString('muxed');
  }
}

class _FakeMediaStore implements IDeviceMediaStore {
  _FakeMediaStore(this.directory);

  final Directory directory;

  @override
  Future<Directory> appDownloadsDirectory() async => directory;

  @override
  Future<void> saveToDownloads(File file, String fileName) async {}

  @override
  Future<void> saveVideoToGallery(File file) async {}
}

void main() {
  late Directory dir;
  late HttpServer server;
  late AppDatabase database;
  final audioBytes = Uint8List.fromList(List.generate(300000, (i) => i % 251));
  final muxedBytes = Uint8List.fromList(List.generate(500000, (i) => i % 241));
  var refuseAudio = false;

  setUp(() async {
    dir = Directory.systemTemp.createTempSync('video_download_repository_test');
    database = AppDatabase(NativeDatabase.memory());
    server = (await HttpServer.bind(InternetAddress.loopbackIPv4, 0))
      ..listen((request) async {
        final content = request.uri.path == '/audio' ? audioBytes : muxedBytes;
        final rangeText =
            request.uri.queryParameters['range'] ??
            request.headers.value('range')!.replaceFirst('bytes=', '');
        final parts = rangeText.split('-');
        final end = parts[1].isEmpty ? content.length - 1 : int.parse(parts[1]);
        final range = [int.parse(parts[0]), end];
        if (request.uri.path == '/audio' && refuseAudio) {
          request.response.statusCode = HttpStatus.forbidden;
        } else {
          request.response.add(content.sublist(range[0], range[1] + 1));
        }
        await request.response.close();
      });
  });

  tearDown(() async {
    await server.close(force: true);
    await database.close();
    dir.deleteSync(recursive: true);
  });

  VideoDownloadRepositoryImpl repository(_FakeMuxer muxer) => VideoDownloadRepositoryImpl(
    streamsClient: YoutubeStreamsClient(
      httpClient: http.Client(),
      youtubeExplode: YoutubeExplode(),
    ),
    downloader: RangedDownloader(createClient: http.Client.new, chunkSize: 100000),
    muxer: muxer,
    mediaStore: _FakeMediaStore(Directory('${dir.path}/saved')..createSync()),
    database: database,
    temporaryDirectory: () async => dir,
  );

  DownloadRequest audioRequest() {
    final base = 'http://${server.address.host}:${server.port}';
    return DownloadRequest(
      video: const VideoItem(id: 'abcdefghijk', title: 'My: Song?', durationText: '3:05'),
      option: DownloadOption.audio(
        audio: _stream(MediaStreamKind.audio, 140, Uri.parse('$base/audio'), audioBytes.length),
        soundFallback: _stream(
          MediaStreamKind.muxed,
          18,
          Uri.parse('$base/muxed'),
          muxedBytes.length,
        ),
      ),
      target: DownloadTarget.appStorage,
    );
  }

  test('saves the audio stream into app storage and records it', () async {
    refuseAudio = false;
    final muxer = _FakeMuxer();
    final progress = await repository(muxer).download(audioRequest()).toList();

    expect(progress.last.phase, DownloadPhase.saving);
    expect(muxer.calls, isEmpty);
    final row = await database.select(database.fileDownloads).getSingle();
    expect(row.mediaType, 'audio');
    expect(row.durationSeconds, 185);
    expect(row.downloadedPath, endsWith('My_ Song_.m4a'));
    expect(File(row.downloadedPath!).readAsBytesSync(), audioBytes);
    // Temporary parts are removed.
    expect(Directory('${dir.path}/ftube_downloads').listSync(), isEmpty);
  });

  test('takes the sound from the fallback stream when the audio stream is refused', () async {
    refuseAudio = true;
    final muxer = _FakeMuxer();
    final progress = await repository(muxer).download(audioRequest()).toList();

    expect(progress.map((p) => p.phase), contains(DownloadPhase.processing));
    expect(muxer.calls, ['extract ${muxedBytes.length}']);
    final row = await database.select(database.fileDownloads).getSingle();
    expect(File(row.downloadedPath!).readAsStringSync(), 'audio-from-muxed');
  });

  test('reports StreamForbiddenException when there is no fallback', () async {
    refuseAudio = true;
    final base = 'http://${server.address.host}:${server.port}';
    final request = DownloadRequest(
      video: const VideoItem(id: 'abcdefghijk', title: 'Song'),
      option: DownloadOption.audio(
        audio: _stream(MediaStreamKind.audio, 140, Uri.parse('$base/audio'), audioBytes.length),
      ),
      target: DownloadTarget.appStorage,
    );
    await expectLater(
      repository(_FakeMuxer()).download(request).drain<void>(),
      throwsA(isA<StreamForbiddenException>()),
    );
    expect(await database.select(database.fileDownloads).get(), isEmpty);
  });
}
