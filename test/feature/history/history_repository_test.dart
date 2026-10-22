import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/history/data/history_repository.dart';

void main() {
  late AppDatabase db;
  late HistoryRepositoryImpl repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = HistoryRepositoryImpl(database: db);
  });
  tearDown(() => db.close());

  Future<void> watch(String id) =>
      db.into(db.videoHistory).insert(VideoItem(id: id, title: id).toHistoryCompanion());

  test('returns the newest videos first and tells whether more exist', () async {
    for (final id in ['a', 'b', 'c']) {
      await watch(id);
    }

    final page = await repository.watchHistory(limit: 2).first;

    expect(page.videos.map((v) => v.id), ['c', 'b']);
    expect(page.hasMore, isTrue);

    final all = await repository.watchHistory(limit: 3).first;
    expect(all.videos.map((v) => v.id), ['c', 'b', 'a']);
    expect(all.hasMore, isFalse);
  });

  test('emits again when the history changes', () async {
    await watch('a');
    final updates = StreamIterator(repository.watchHistory(limit: 15));
    expect(await updates.moveNext(), isTrue);
    expect(updates.current.videos.map((v) => v.id), ['a']);

    await watch('b');
    expect(await updates.moveNext(), isTrue);
    expect(updates.current.videos.map((v) => v.id), ['b', 'a']);

    await updates.cancel();
  });
}
