import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart' show getDatabasesPath;
import 'package:youtube/src/common/database/tables/file_downloads_table.dart';
import 'package:youtube/src/common/database/tables/likes_table.dart';
import 'package:youtube/src/common/database/tables/playlist_videos_table.dart';
import 'package:youtube/src/common/database/tables/playlists_table.dart';
import 'package:youtube/src/common/database/tables/video_history_table.dart';

part 'database.g.dart';

/// {@template database}
/// The app database. Migrations are written by hand: drift's generated step-by-step helper cannot
/// represent the legacy `date_time` column (its getter would clash with `Table.dateTime`).
/// It opens the file the earlier Floor implementation created (`ftube.db`,
/// schema v5), so history, likes, playlists and downloads survive the upgrade.
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
      if (from < 6) {
        await m.addColumn(fileDownloads, fileDownloads.videoId);
        await m.addColumn(fileDownloads, fileDownloads.mediaType);
        await m.addColumn(fileDownloads, fileDownloads.durationSeconds);
      }
    },
  );
}
