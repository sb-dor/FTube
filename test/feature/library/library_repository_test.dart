import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/library/data/library_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

VideoItem _video(String id) => VideoItem(id: id, title: id);

void main() {
  late AppDatabase db;
  late LibraryRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = LibraryRepositoryImpl(database: db, sectionLimit: 3);
  });
  tearDown(() => db.close());

  test('is empty for a new database', () async {
    final overview = await repository.watchOverview().first;
    expect(overview.isEmpty, isTrue);
  });

  test('shows the newest history, liked first then the newest playlists, and downloads', () async {
    for (var i = 0; i < 5; i++) {
      await db.into(db.videoHistory).insert(_video('h$i').toHistoryCompanion());
      await db.into(db.playlists).insert(PlaylistsCompanion.insert(name: Value('P$i')));
    }
    await db.into(db.likes).insert(_video('l').toLikeCompanion());
    await db.into(db.fileDownloads).insert(FileDownloadsCompanion.insert(name: const Value('f')));

    final overview = await repository.watchOverview().first;

    expect(overview.history.map((v) => v.id), ['h4', 'h3', 'h2']);
    expect(overview.playlists.first, isA<LikedPlaylistSummary>());
    expect(overview.playlists.skip(1).map((p) => (p as UserPlaylistSummary).name), [
      'P4',
      'P3',
      'P2',
    ]);
    expect(overview.downloadsCount, 1);
    expect(overview.isEmpty, isFalse);
  });

  test('updates by itself when another feature writes', () async {
    final updates = StreamIterator(repository.watchOverview());
    expect(await updates.moveNext(), isTrue);
    expect(updates.current.history, isEmpty);

    await db.into(db.videoHistory).insert(_video('a').toHistoryCompanion());
    expect(await updates.moveNext(), isTrue);
    expect(updates.current.history.map((v) => v.id), ['a']);

    await db.into(db.fileDownloads).insert(FileDownloadsCompanion.insert(name: const Value('f')));
    expect(await updates.moveNext(), isTrue);
    expect(updates.current.downloadsCount, 1);

    await updates.cancel();
  });
}
