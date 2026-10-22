import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/history_deletion/data/history_deletion_repository.dart';

void main() {
  late AppDatabase db;
  late HistoryDeletionRepositoryImpl repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = HistoryDeletionRepositoryImpl(database: db);
    for (final id in ['a', 'b', 'c']) {
      await db.into(db.videoHistory).insert(VideoItem(id: id, title: id).toHistoryCompanion());
    }
  });
  tearDown(() => db.close());

  Future<List<String?>> ids() async =>
      (await db.select(db.videoHistory).get()).map((row) => row.videoId).toList();

  test('remove deletes only that video', () async {
    await repository.remove('b');
    expect(await ids(), ['a', 'c']);
  });

  test('clear deletes everything', () async {
    await repository.clear();
    expect(await ids(), isEmpty);
  });
}
