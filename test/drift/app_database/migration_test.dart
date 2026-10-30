import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/database/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // Verifies every schema upgrade with an empty database.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = AppDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  test('migration from v5 to v6 does not corrupt data', () async {
    const oldHistory = [
      v5.VideoHistoryData(id: 1, videoId: 'abc', title: 'Watched', dateTime$: '2025-01-01'),
    ];
    const expectedHistory = [
      v6.VideoHistoryData(id: 1, videoId: 'abc', title: 'Watched', dateTime$: '2025-01-01'),
    ];
    const oldDownloads = [
      v5.FileDownloadsData(id: 1, name: 'Song', downloadedPath: '/files/song.mp3'),
    ];
    const expectedDownloads = [
      v6.FileDownloadsData(id: 1, name: 'Song', downloadedPath: '/files/song.mp3'),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch
        ..insertAll(oldDb.videoHistory, oldHistory)
        ..insertAll(oldDb.fileDownloads, oldDownloads),
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.videoHistory).get(), expectedHistory);
        expect(await newDb.select(newDb.fileDownloads).get(), expectedDownloads);
      },
    );
  });
}
