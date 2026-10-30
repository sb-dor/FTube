import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import 'package:youtube/src/common/database/database.steps.dart';
import 'package:youtube/src/common/database/tables/file_downloads_table.dart';
import 'package:youtube/src/common/database/tables/likes_table.dart';
import 'package:youtube/src/common/database/tables/playlist_videos_table.dart';
import 'package:youtube/src/common/database/tables/playlists_table.dart';
import 'package:youtube/src/common/database/tables/video_history_table.dart';

part 'database.g.dart';

/// {@template database}
/// The app database. It opens the file the earlier Floor implementation created (`ftube.db`,
/// schema v5), so history, likes, playlists and downloads survive the upgrade. Later versions
/// migrate step by step through `database.steps.dart` (`dart run drift_dev make-migrations`).
/// {@endtemplate}
@DriftDatabase(tables: [VideoHistory, Playlists, PlaylistVideos, Likes, FileDownloads])
class AppDatabase extends _$AppDatabase {
  /// {@macro database}
  AppDatabase(super.e);

  /// Opens `ftube.db` in the platform databases directory.
  factory AppDatabase.defaults() => AppDatabase(
    driftDatabase(
      name: 'ftube',
      native: DriftNativeOptions(
        databasePath: () async => p.join(await getDatabasesPath(), 'ftube.db'),
      ),
    ),
  );

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // The Floor implementation could only migrate from v4, so a database older than v5 never
      // opened there either; it is recreated empty.
      if (from < 5) {
        for (final table in allTables) {
          await m.deleteTable(table.actualTableName);
        }
        await m.createAll();
        return;
      }
      await _stepByStep(m, from, to);
    },
  );

  static final OnUpgrade _stepByStep = stepByStep(
    from5To6: (m, schema) async {
      await m.addColumn(schema.fileDownloads, schema.fileDownloads.videoId);
      await m.addColumn(schema.fileDownloads, schema.fileDownloads.mediaType);
      await m.addColumn(schema.fileDownloads, schema.fileDownloads.durationSeconds);
    },
  );
}
