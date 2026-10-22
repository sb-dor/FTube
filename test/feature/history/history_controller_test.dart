import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/history/controller/history_controller.dart';
import 'package:youtube/src/feature/history/data/history_repository.dart';

class _MockHistoryRepository extends Mock implements IHistoryRepository {}

List<VideoItem> _videos(int count) => [
  for (var i = 0; i < count; i++) VideoItem(id: '$i', title: '$i'),
];

void main() {
  late _MockHistoryRepository repository;
  late Map<int, StreamController<VideoListPage>> sources;
  late HistoryController controller;

  setUp(() {
    repository = _MockHistoryRepository();
    sources = {};
    when(() => repository.watchHistory(limit: any(named: 'limit'))).thenAnswer((invocation) {
      final limit = invocation.namedArguments[#limit] as int;
      return (sources[limit] = StreamController<VideoListPage>()).stream;
    });
    controller = HistoryController(historyRepository: repository, pageSize: 2);
  });

  tearDown(() {
    controller.dispose();
    for (final source in sources.values) {
      source.close();
    }
  });

  Future<void> emit(int limit, VideoListPage page) async {
    while (sources[limit] == null) {
      await Future<void>.delayed(Duration.zero);
    }
    sources[limit]!.add(page);
  }

  test('load watches the first page', () async {
    controller.load();
    await emit(2, (videos: _videos(2), hasMore: true));
    await controller.waitFor((state) => state is History$CompletedState);

    final state = controller.state as History$CompletedState;
    expect(state.videos, _videos(2));
    expect(state.limit, 2);
    expect(state.canLoadMore, isTrue);
  });

  test('paginate widens the watched window and stays busy until it arrives', () async {
    controller.load();
    await emit(2, (videos: _videos(2), hasMore: true));
    await controller.waitFor((state) => state is History$CompletedState);

    controller.paginate();
    await Future<void>.delayed(Duration.zero);
    expect(controller.isProcessing, isTrue);

    await emit(4, (videos: _videos(3), hasMore: false));
    await controller.waitFor((state) => state is History$CompletedState && state.limit == 4);
    expect(controller.state.canLoadMore, isFalse);
    expect((controller.state as History$CompletedState).videos, _videos(3));
    expect(sources[2]!.hasListener, isFalse);
  });

  test('later emissions replace the page (e.g. after a removal)', () async {
    controller.load();
    await emit(2, (videos: _videos(2), hasMore: false));
    await controller.waitFor((state) => state is History$CompletedState);

    await emit(2, (videos: _videos(1), hasMore: false));
    await controller.waitFor(
      (state) => state is History$CompletedState && state.videos.length == 1,
    );
  });

  test('paginate does nothing when there is no next page', () async {
    controller.load();
    await emit(2, (videos: _videos(1), hasMore: false));
    await controller.waitFor((state) => state is History$CompletedState);

    controller.paginate();
    await Future<void>.delayed(Duration.zero);
    verify(() => repository.watchHistory(limit: 2)).called(1);
    verifyNever(() => repository.watchHistory(limit: 4));
  });

  test('a failing stream moves to error', () async {
    controller.load();
    while (sources[2] == null) {
      await Future<void>.delayed(Duration.zero);
    }
    sources[2]!.addError(StateError('db'));
    await controller.waitFor((state) => state is History$ErrorState);
  });
}
