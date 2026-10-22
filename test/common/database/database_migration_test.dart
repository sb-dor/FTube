import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:youtube/src/common/database/database.dart';

/// The schema Floor created in app version 1.0.6 (Floor database version 5).
const _floorV5 = [
  'CREATE TABLE IF NOT EXISTS `video_history` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `videoId` TEXT, `videoThumbnailUrl` TEXT, `views` TEXT, `duration` TEXT, `title` TEXT, `channelName` TEXT, `channelThumb` TEXT, `videoDate` TEXT, `date_time` TEXT)',
  'CREATE TABLE IF NOT EXISTS `playlists` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT)',
  'CREATE TABLE IF NOT EXISTS `playlist_videos` (`play_list_id` INTEGER, `id` INTEGER PRIMARY KEY AUTOINCREMENT, `videoId` TEXT, `videoThumbnailUrl` TEXT, `views` TEXT, `duration` TEXT, `title` TEXT, `channelName` TEXT, `channelThumb` TEXT, `videoDate` TEXT, `date_time` TEXT, FOREIGN KEY (`play_list_id`) REFERENCES `playlists` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)',
  'CREATE TABLE IF NOT EXISTS `likes_table` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `videoId` TEXT, `videoThumbnailUrl` TEXT, `views` TEXT, `duration` TEXT, `title` TEXT, `channelName` TEXT, `channelThumb` TEXT, `videoDate` TEXT, `date_time` TEXT)',
  'CREATE TABLE IF NOT EXISTS `file_downloads` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT, `downloaded_path` TEXT, `image_path` TEXT, `views` TEXT, `created_at` TEXT, `channel_name` TEXT)',
];

void main() {
  late Directory dir;
  late File file;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('ftube_db_test');
    file = File('${dir.path}/ftube.db');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  test('opens a Floor v5 database and keeps its rows', () async {
    final legacy = sqlite3.open(file.path);
    _floorV5.forEach(legacy.execute);
    legacy
      ..execute(
        "INSERT INTO video_history (videoId, title, date_time) VALUES ('abc', 'Watched', '2025-01-01')",
      )
      ..execute("INSERT INTO playlists (name) VALUES ('Music')")
      ..execute("INSERT INTO playlist_videos (play_list_id, videoId) VALUES (1, 'def')")
      ..execute("INSERT INTO likes_table (videoId) VALUES ('ghi')")
      ..execute(
        "INSERT INTO file_downloads (name, downloaded_path) VALUES ('Song', '/files/song.mp3')",
      )
      ..execute('PRAGMA user_version = 5')
      ..close();

    final db = AppDatabase(NativeDatabase(file));
    final history = await db.select(db.videoHistory).getSingle();
    expect(history.videoId, 'abc');
    expect(history.savedAt, '2025-01-01');
    expect((await db.select(db.playlists).getSingle()).name, 'Music');
    expect((await db.select(db.playlistVideos).getSingle()).playlistId, 1);
    expect((await db.select(db.likes).getSingle()).videoId, 'ghi');
    final download = await db.select(db.fileDownloads).getSingle();
    expect(download.downloadedPath, '/files/song.mp3');
    expect(download.mediaType, isNull);

    await db
        .into(db.fileDownloads)
        .insert(
          FileDownloadsCompanion.insert(
            mediaType: const Value('video'),
            durationSeconds: const Value(60),
          ),
        );
    expect(await db.select(db.fileDownloads).get(), hasLength(2));
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, 6);
    await db.close();
  });

  test('creates a fresh database at the current version', () async {
    final db = AppDatabase(NativeDatabase(file));
    expect(await db.select(db.videoHistory).get(), isEmpty);
    final version = await db.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, db.schemaVersion);
    await db.close();
  });
}
