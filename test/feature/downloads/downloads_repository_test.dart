import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/feature/downloads/data/downloads_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

void main() {
  late AppDatabase db;
  late Directory dir;
  late Directory storage;
  late DownloadsRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    dir = Directory.systemTemp.createTempSync('ftube_downloads_test');
    storage = Directory(p.join(dir.path, 'storage'))..createSync();
    repository = DownloadsRepositoryImpl(database: db, storageDirectories: () async => [storage]);
  });

  tearDown(() async {
    await db.close();
    dir.deleteSync(recursive: true);
  });

  String createFile(String path) {
    File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync('data');
    return path;
  }

  Future<int> insert({
    String? name,
    String? path,
    String? mediaType,
    String? videoId,
    String? imagePath,
    int? durationSeconds,
  }) => db
      .into(db.fileDownloads)
      .insert(
        FileDownloadsCompanion.insert(
          name: Value(name),
          downloadedPath: Value(path),
          imagePath: Value(imagePath),
          views: const Value('1K views'),
          channelName: const Value('Channel'),
          mediaType: Value(mediaType),
          videoId: Value(videoId),
          durationSeconds: Value(durationSeconds),
        ),
      );

  test('lists downloads newest first with their details', () async {
    final video = createFile(p.join(dir.path, 'video.mp4'));
    final audio = createFile(p.join(dir.path, 'song.m4a'));
    await insert(name: 'Video', path: video, mediaType: 'video', imagePath: 'https://img/1.jpg');
    await insert(
      name: 'Song',
      path: audio,
      mediaType: 'audio',
      videoId: 'abc',
      durationSeconds: 61,
    );

    final downloads = await repository.watchDownloads().first;

    expect(downloads.map((file) => file.title), ['Song', 'Video']);
    final song = downloads.first;
    expect(song.path, audio);
    expect(song.exists, isTrue);
    expect(song.mediaType, DownloadMediaType.audio);
    expect(song.typeLabel, 'M4A');
    expect(song.channelName, 'Channel');
    expect(song.viewsText, '1K views');
    expect(song.duration, const Duration(seconds: 61));
    expect(song.thumbnailUrl, 'https://i.ytimg.com/vi/abc/hqdefault.jpg');
    expect(downloads.last.thumbnailUrl, 'https://img/1.jpg');
    expect(downloads.last.typeLabel, 'MP4');
  });

  test('infers the media type of old rows from the file extension', () async {
    await insert(name: 'Old audio', path: createFile(p.join(dir.path, 'a.mp3')));
    await insert(name: 'Old video', path: createFile(p.join(dir.path, 'v.mp4')));

    final downloads = await repository.watchDownloads().first;

    expect(downloads.map((file) => file.mediaType), [
      DownloadMediaType.video,
      DownloadMediaType.audio,
    ]);
  });

  test('keeps rows whose file is gone, marked as missing', () async {
    await insert(name: 'Gone', path: p.join(dir.path, 'gone.mp4'));
    await insert(name: 'No path');

    final downloads = await repository.watchDownloads().first;

    expect(downloads, hasLength(2));
    expect(downloads.every((file) => !file.exists), isTrue);
    expect(downloads.last.path, p.join(dir.path, 'gone.mp4'));
  });

  test('finds a moved file by name in the storage directories', () async {
    const oldRoot = '/var/mobile/Containers/Data/Application/OLD/Documents';
    final direct = createFile(p.join(storage.path, 'direct.mp4'));
    final nested = createFile(p.join(storage.path, 'downloads', 'nested.m4a'));
    await insert(name: 'Direct', path: '$oldRoot/direct.mp4');
    await insert(name: 'Nested', path: '$oldRoot/downloads/nested.m4a');

    final downloads = await repository.watchDownloads().first;

    expect(downloads.map((file) => file.path), [nested, direct]);
    expect(downloads.every((file) => file.exists), isTrue);
    expect(downloads.first.storedPath, '$oldRoot/downloads/nested.m4a');
  });

  test('emits again when a download is added or deleted', () async {
    final emissions = <List<DownloadedFile>>[];
    final subscription = repository.watchDownloads().listen(emissions.add);
    addTearDown(subscription.cancel);
    await pumpEventQueue();
    expect(emissions.last, isEmpty);

    final id = await insert(name: 'New', path: createFile(p.join(dir.path, 'new.mp4')));
    await pumpEventQueue();
    expect(emissions.last.single.title, 'New');

    await (db.delete(db.fileDownloads)..where((table) => table.id.equals(id))).go();
    await pumpEventQueue();
    expect(emissions.last, isEmpty);
  });

  test('DownloadMediaType.resolve prefers the stored type', () {
    expect(DownloadMediaType.resolve('video', '/a.m4a'), DownloadMediaType.video);
    expect(DownloadMediaType.resolve('audio', '/a.mp4'), DownloadMediaType.audio);
    expect(DownloadMediaType.resolve(null, '/a.OPUS'), DownloadMediaType.audio);
    expect(DownloadMediaType.resolve(null, '/a.webm'), DownloadMediaType.video);
    expect(DownloadMediaType.resolve(null, ''), DownloadMediaType.video);
  });
}
