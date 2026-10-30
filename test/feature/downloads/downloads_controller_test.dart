import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/feature/downloads/controller/downloads_controller.dart';
import 'package:youtube/src/feature/downloads/data/downloads_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

class _MockDownloadsRepository extends Mock implements IDownloadsRepository {}

DownloadedFile _file(int id) => DownloadedFile(
  id: id,
  title: 'File $id',
  path: '/files/$id.m4a',
  mediaType: DownloadMediaType.audio,
  exists: true,
);

void main() {
  late _MockDownloadsRepository repository;
  late Map<int, StreamController<DownloadsPage>> pages;
  late DownloadsController controller;

  /// The stream the repository returned for [limit].
  StreamController<DownloadsPage> page(int limit) => pages[limit]!;

  setUp(() {
    repository = _MockDownloadsRepository();
    pages = {};
    when(() => repository.watchDownloads(limit: any(named: 'limit'))).thenAnswer((invocation) {
      final limit = invocation.namedArguments[#limit] as int;
      return (pages[limit] = StreamController<DownloadsPage>()).stream;
    });
    controller = DownloadsController(downloadsRepository: repository, pageSize: 2);
  });

  tearDown(() async {
    if (!controller.isDisposed) controller.dispose();
    for (final stream in pages.values) {
      unawaited(stream.close());
    }
  });

  test('load watches the first page and keeps emitting its changes', () async {
    controller.load();
    await pumpEventQueue();
    expect(controller.state, isA<Downloads$InProgressState>());
    expect(controller.isProcessing, isTrue);

    page(2).add((downloads: [_file(2), _file(1)], hasMore: false));
    await pumpEventQueue();
    expect(
      controller.state,
      DownloadsState.completed(downloads: [_file(2), _file(1)], limit: 2, hasMore: false),
    );
    expect(controller.isProcessing, isFalse);

    page(2).add((downloads: const [], hasMore: false));
    await pumpEventQueue();
    expect(
      controller.state,
      const DownloadsState.completed(downloads: [], limit: 2, hasMore: false),
    );
  });

  test('paginate widens the window without going through inProgress', () async {
    controller.load();
    await pumpEventQueue();
    page(2).add((downloads: [_file(4), _file(3)], hasMore: true));
    await pumpEventQueue();
    expect(controller.state.canLoadMore, isTrue);

    final states = <DownloadsState>[];
    controller
      ..addListener(() => states.add(controller.state))
      ..paginate();
    await pumpEventQueue();
    expect(page(2).hasListener, isFalse);
    expect(states, isEmpty);

    page(4).add((downloads: [_file(4), _file(3), _file(2), _file(1)], hasMore: false));
    await pumpEventQueue();
    expect(states.whereType<Downloads$InProgressState>(), isEmpty);
    expect(
      controller.state,
      isA<Downloads$CompletedState>()
          .having((s) => s.downloads, 'downloads', hasLength(4))
          .having((s) => s.limit, 'limit', 4)
          .having((s) => s.hasMore, 'hasMore', isFalse),
    );
  });

  test('paginate does nothing on the last page or before the first page', () async {
    controller.paginate();
    await pumpEventQueue();
    verifyNever(() => repository.watchDownloads(limit: any(named: 'limit')));

    controller.load();
    await pumpEventQueue();
    page(2).add((downloads: [_file(1)], hasMore: false));
    await pumpEventQueue();

    controller.paginate();
    await pumpEventQueue();
    verify(() => repository.watchDownloads(limit: 2)).called(1);
    verifyNever(() => repository.watchDownloads(limit: 4));
  });

  test('a stream error becomes the error state; load starts over from the first page', () async {
    controller.load();
    await pumpEventQueue();
    page(2).addError(StateError('db'));
    await pumpEventQueue();
    expect(controller.state, isA<Downloads$ErrorState>());

    controller.load();
    await pumpEventQueue();
    page(2).add((downloads: [_file(1)], hasMore: false));
    await pumpEventQueue();
    expect(controller.state, isA<Downloads$CompletedState>());
  });

  test('dispose stops watching', () async {
    controller.load();
    await pumpEventQueue();
    controller.dispose();
    await pumpEventQueue();
    expect(page(2).hasListener, isFalse);
  });
}
