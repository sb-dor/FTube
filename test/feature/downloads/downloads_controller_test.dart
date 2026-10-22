import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/feature/downloads/controller/downloads_controller.dart';
import 'package:youtube/src/feature/downloads/data/downloads_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

class _MockDownloadsRepository extends Mock implements IDownloadsRepository {}

const _file = DownloadedFile(
  id: 1,
  title: 'Song',
  path: '/files/song.m4a',
  mediaType: DownloadMediaType.audio,
  exists: true,
);

void main() {
  late _MockDownloadsRepository repository;
  late StreamController<List<DownloadedFile>> downloads;
  late DownloadsController controller;

  setUp(() {
    repository = _MockDownloadsRepository();
    downloads = StreamController<List<DownloadedFile>>();
    when(repository.watchDownloads).thenAnswer((_) => downloads.stream);
    controller = DownloadsController(downloadsRepository: repository);
  });

  tearDown(() async {
    if (!controller.isDisposed) controller.dispose();
    unawaited(downloads.close());
  });

  test('watch emits every change of the downloads', () async {
    controller.watch();
    await pumpEventQueue();
    expect(controller.state, isA<Downloads$InProgressState>());

    downloads.add(const [_file]);
    await pumpEventQueue();
    expect(controller.state, const DownloadsState.completed(downloads: [_file]));

    downloads.add(const []);
    await pumpEventQueue();
    expect(controller.state, const DownloadsState.completed(downloads: []));
  });

  test('a stream error becomes the error state', () async {
    controller.watch();
    await pumpEventQueue();
    downloads.addError(StateError('db'));
    await pumpEventQueue();
    expect(controller.state, isA<Downloads$ErrorState>());
  });

  test('watching again replaces the previous subscription', () async {
    controller.watch();
    await pumpEventQueue();
    expect(downloads.hasListener, isTrue);

    final second = StreamController<List<DownloadedFile>>();
    addTearDown(second.close);
    when(repository.watchDownloads).thenAnswer((_) => second.stream);
    controller.watch();
    await pumpEventQueue();

    expect(downloads.hasListener, isFalse);
    second.add(const [_file]);
    await pumpEventQueue();
    expect(controller.state, const DownloadsState.completed(downloads: [_file]));
  });

  test('dispose stops watching', () async {
    controller.watch();
    await pumpEventQueue();
    controller.dispose();
    await pumpEventQueue();
    expect(downloads.hasListener, isFalse);
  });
}
