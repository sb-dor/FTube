import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/feature/trending/controller/trending_controller.dart';
import 'package:youtube/src/feature/trending/data/trending_repository.dart';
import 'package:youtube/src/feature/trending/models/trending_category.dart';

class _MockTrendingRepository extends Mock implements ITrendingRepository {}

VideoItem _video(String id) => VideoItem(id: id, title: 'Video $id');

void main() {
  late _MockTrendingRepository repository;
  late TrendingController controller;
  const query = 'popular videos';
  const filter = 'CAMSBAgDEAE=';

  setUp(() {
    repository = _MockTrendingRepository();
    controller = TrendingController(trendingRepository: repository);
  });

  tearDown(() => controller.dispose());

  /// Lets the controller finish every queued handler.
  Future<void> idle() async {
    do {
      await Future<void>.delayed(Duration.zero);
    } while (controller.isProcessing);
  }

  void stubFirstPage(VideoPage page) =>
      when(() => repository.videos(query: query, filter: filter)).thenAnswer((_) async => page);

  test('every category uses the weekly most-viewed filter', () {
    for (final category in TrendingCategory.values) {
      expect(category.filter, filter);
    }
    expect(TrendingCategory.values.first, TrendingCategory.now);
  });

  test('load goes through inProgress to completed with the continuation', () async {
    stubFirstPage(VideoPage(videos: [_video('a'), _video('b')], continuation: 'next'));
    final states = <TrendingState>[];
    controller
      ..addListener(() => states.add(controller.state))
      ..load(query: query, filter: filter);
    await idle();

    expect(states.first, isA<Trending$InProgressState>());
    final state = controller.state as Trending$CompletedState;
    expect(state.videos.map((v) => v.id), ['a', 'b']);
    expect(state.continuation, 'next');
    expect(state.hasMore, isTrue);
  });

  test('load error sets the error state', () async {
    final error = Exception('offline');
    when(() => repository.videos(query: query, filter: filter)).thenThrow(error);
    controller.load(query: query, filter: filter);
    await idle();

    expect(controller.state, isA<Trending$ErrorState>());
    expect((controller.state as Trending$ErrorState).error, error);
    expect(controller.state.hasMore, isFalse);
  });

  test('paginate appends the next page without duplicates and never sets inProgress', () async {
    stubFirstPage(VideoPage(videos: [_video('a'), _video('b')], continuation: 'next'));
    when(() => repository.videos(query: query, filter: filter, continuation: 'next'))
        .thenAnswer((_) async => VideoPage(videos: [_video('b'), _video('c')]));
    controller.load(query: query, filter: filter);
    await idle();

    final states = <TrendingState>[];
    controller
      ..addListener(() => states.add(controller.state))
      ..paginate(query: query, filter: filter);
    await idle();

    expect(states.whereType<Trending$InProgressState>(), isEmpty);
    final state = controller.state as Trending$CompletedState;
    expect(state.videos.map((v) => v.id), ['a', 'b', 'c']);
    expect(state.continuation, isNull);
    expect(state.hasMore, isFalse);
  });

  test('paginate does nothing without a continuation or before a load', () async {
    controller.paginate(query: query, filter: filter);
    await idle();
    expect(controller.state, isA<Trending$InitialState>());

    stubFirstPage(VideoPage(videos: [_video('a')]));
    controller
      ..load(query: query, filter: filter)
      ..paginate(query: query, filter: filter);
    await idle();

    expect((controller.state as Trending$CompletedState).videos.map((v) => v.id), ['a']);
    verify(() => repository.videos(query: query, filter: filter)).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('paginate error sets the error state', () async {
    stubFirstPage(VideoPage(videos: [_video('a')], continuation: 'next'));
    when(() => repository.videos(query: query, filter: filter, continuation: 'next'))
        .thenThrow(Exception('boom'));
    controller.load(query: query, filter: filter);
    await idle();
    controller.paginate(query: query, filter: filter);
    await idle();

    expect(controller.state, isA<Trending$ErrorState>());
  });

  test('a new load replaces the previous list', () async {
    stubFirstPage(VideoPage(videos: [_video('a')], continuation: 'next'));
    when(() => repository.videos(query: 'trailer', filter: filter))
        .thenAnswer((_) async => VideoPage(videos: [_video('z')]));
    controller.load(query: query, filter: filter);
    await idle();
    controller.load(query: 'trailer', filter: filter);
    await idle();

    final state = controller.state as Trending$CompletedState;
    expect(state.videos.map((v) => v.id), ['z']);
    expect(state.hasMore, isFalse);
  });
}
