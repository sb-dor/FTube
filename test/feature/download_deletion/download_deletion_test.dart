import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/feature/download_deletion/controller/download_deletion_controller.dart';
import 'package:youtube/src/feature/download_deletion/data/download_deletion_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

class _MockDownloadDeletionRepository extends Mock implements IDownloadDeletionRepository {}

DownloadedFile _file(int id, String path, {String? storedPath, bool exists = true}) =>
    DownloadedFile(
      id: id,
      title: 'File $id',
      path: path,
      storedPath: storedPath ?? path,
      mediaType: DownloadMediaType.video,
      exists: exists,
    );

void main() {
  group('DownloadDeletionRepositoryImpl', () {
    late AppDatabase db;
    late Directory dir;
    late DownloadDeletionRepositoryImpl repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      dir = Directory.systemTemp.createTempSync('ftube_deletion_test');
      repository = DownloadDeletionRepositoryImpl(database: db);
    });

    tearDown(() async {
      await db.close();
      dir.deleteSync(recursive: true);
    });

    Future<int> insert(String path) => db
        .into(db.fileDownloads)
        .insert(FileDownloadsCompanion.insert(downloadedPath: Value(path)));

    test('deletes the file and its row only', () async {
      final path = p.join(dir.path, 'video.mp4');
      File(path).writeAsStringSync('data');
      final keptPath = p.join(dir.path, 'kept.mp4');
      File(keptPath).writeAsStringSync('data');
      final id = await insert(path);
      final keptId = await insert(keptPath);

      await repository.delete(_file(id, path));

      expect(File(path).existsSync(), isFalse);
      expect(File(keptPath).existsSync(), isTrue);
      final rows = await db.select(db.fileDownloads).get();
      expect(rows.map((row) => row.id), [keptId]);
    });

    test('deletes a moved file found at another path', () async {
      final moved = p.join(dir.path, 'moved.mp4');
      File(moved).writeAsStringSync('data');
      final id = await insert('/old/container/moved.mp4');

      await repository.delete(_file(id, moved, storedPath: '/old/container/moved.mp4'));

      expect(File(moved).existsSync(), isFalse);
      expect(await db.select(db.fileDownloads).get(), isEmpty);
    });

    test('removes the row of a file that is already gone', () async {
      final path = p.join(dir.path, 'gone.mp4');
      final id = await insert(path);

      await repository.delete(_file(id, path, exists: false));

      expect(await db.select(db.fileDownloads).get(), isEmpty);
    });
  });

  group('DownloadDeletionController', () {
    late _MockDownloadDeletionRepository repository;
    late DownloadDeletionController controller;
    final file = _file(1, '/files/video.mp4');

    setUp(() {
      repository = _MockDownloadDeletionRepository();
      controller = DownloadDeletionController(downloadDeletionRepository: repository);
    });

    tearDown(() => controller.dispose());

    test('completes after deleting', () async {
      when(() => repository.delete(file)).thenAnswer((_) async {});
      final states = <DownloadDeletionState>[];
      controller.addListener(() => states.add(controller.state));

      controller.delete(file);
      await pumpEventQueue();

      expect(states, [
        const DownloadDeletionState.inProgress(),
        const DownloadDeletionState.completed(),
      ]);
      verify(() => repository.delete(file)).called(1);
    });

    test('reports a failure', () async {
      when(() => repository.delete(file)).thenThrow(const FileSystemException('denied'));

      controller.delete(file);
      await pumpEventQueue();

      expect(controller.state, isA<DownloadDeletion$ErrorState>());
    });

    test('drops a second tap while deleting', () async {
      when(() => repository.delete(file)).thenAnswer((_) => Future<void>.delayed(Duration.zero));

      controller
        ..delete(file)
        ..delete(file);
      await pumpEventQueue();

      verify(() => repository.delete(file)).called(1);
    });
  });
}
