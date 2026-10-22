import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/feature/search/controller/search_results_controller.dart';
import 'package:youtube/src/feature/search/data/search_repository.dart';

class _MockSearchRepository extends Mock implements ISearchRepository {}

VideoItem _video(String id) => VideoItem(id: id, title: 'Video $id');

VideoPage _page(List<String> ids, [String? continuation]) =>
    VideoPage(videos: ids.map(_video).toList(), continuation: continuation);

/// Lets the controller's queued handlers run.
Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockSearchRepository repository;
  late SearchResultsController controller;

  setUp(() {
    repository = _MockSearchRepository();
    controller = SearchResultsController(searchRepository: repository);
  });

  tearDown(() => controller.dispose());

  void stubFirstPage(VideoPage page, {String query = 'cats', String? filter = 'EgIQAQ=='}) =>
      when(() => repository.videos(query: query, filter: filter)).thenAnswer((_) async => page);

  void stubNextPage(String continuation, VideoPage page) => when(
    () => repository.videos(
      query: any(named: 'query'),
      filter: any(named: 'filter'),
      continuation: continuation,
    ),
  ).thenAnswer((_) async => page);

  List<String> ids() => controller.state is SearchResults$CompletedState
      ? (controller.state as SearchResults$CompletedState).videos.map((v) => v.id).toList()
      : const [];

  test('load shows progress, then the first page and its continuation', () async {
    stubFirstPage(_page(['a', 'b'], 'token1'));
    final states = <SearchResultsState>[];
    controller.addListener(() => states.add(controller.state));

    controller.load(query: 'cats', filter: 'EgIQAQ==');
    await _settle();

    expect(states.first, isA<SearchResults$InProgressState>());
    expect(controller.state, isA<SearchResults$CompletedState>());
    expect((controller.state as SearchResults$CompletedState).continuation, 'token1');
    expect(ids(), ['a', 'b']);
    expect(controller.state.hasMore, isTrue);
  });

  test('paginate requests the stored continuation and appends without duplicates', () async {
    stubFirstPage(_page(['a', 'b'], 'token1'));
    stubNextPage('token1', _page(['b', 'c'], 'token2'));
    stubNextPage('token2', _page(['d']));

    controller.load(query: 'cats', filter: 'EgIQAQ==');
    await _settle();
    controller.paginate(query: 'cats', filter: 'EgIQAQ==');
    await _settle();
    expect(ids(), ['a', 'b', 'c']);
    expect((controller.state as SearchResults$CompletedState).continuation, 'token2');

    controller.paginate(query: 'cats', filter: 'EgIQAQ==');
    await _settle();
    expect(ids(), ['a', 'b', 'c', 'd']);
    expect(controller.state.hasMore, isFalse);

    // The last page has no continuation: further calls do not hit the repository.
    controller.paginate(query: 'cats', filter: 'EgIQAQ==');
    await _settle();
    verify(
      () => repository.videos(
        query: any(named: 'query'),
        filter: any(named: 'filter'),
        continuation: any(named: 'continuation'),
      ),
    ).called(3);
  });

  test('paginate never shows progress over the loaded list', () async {
    stubFirstPage(_page(['a'], 'token1'));
    final next = Completer<VideoPage>();
    when(
      () => repository.videos(
        query: any(named: 'query'),
        filter: any(named: 'filter'),
        continuation: 'token1',
      ),
    ).thenAnswer((_) => next.future);

    controller.load(query: 'cats', filter: 'EgIQAQ==');
    await _settle();
    controller.paginate(query: 'cats', filter: 'EgIQAQ==');
    await _settle();
    expect(controller.isProcessing, isTrue);
    expect(ids(), ['a']);

    next.complete(_page(['b']));
    await _settle();
    expect(ids(), ['a', 'b']);
  });

  test('paginate queued behind load uses the continuation load produced', () async {
    stubFirstPage(_page(['a'], 'token1'));
    stubNextPage('token1', _page(['b'], 'token2'));

    controller
      ..load(query: 'cats', filter: 'EgIQAQ==')
      ..paginate(query: 'cats', filter: 'EgIQAQ==');
    await _settle();

    expect(ids(), ['a', 'b']);
  });

  test('paginate before any load does nothing', () async {
    controller.paginate(query: 'cats');
    await _settle();
    expect(controller.state, isA<SearchResults$InitialState>());
    verifyNever(
      () => repository.videos(
        query: any(named: 'query'),
        filter: any(named: 'filter'),
        continuation: any(named: 'continuation'),
      ),
    );
  });

  test('a new load replaces the previous results', () async {
    stubFirstPage(_page(['a'], 'token1'));
    stubFirstPage(_page(['x']), query: 'dogs', filter: 'EgQIARAB');

    controller.load(query: 'cats', filter: 'EgIQAQ==');
    await _settle();
    controller.load(query: 'dogs', filter: 'EgQIARAB');
    await _settle();

    expect(ids(), ['x']);
    expect(controller.state.hasMore, isFalse);
  });

  test('load and paginate failures end in the error state', () async {
    when(() => repository.videos(query: 'cats', filter: null))
        .thenAnswer((_) async => throw Exception('offline'));
    controller.load(query: 'cats');
    await _settle();
    expect(controller.state, isA<SearchResults$ErrorState>());

    stubFirstPage(_page(['a'], 'token1'), filter: null);
    when(
      () => repository.videos(
        query: any(named: 'query'),
        filter: any(named: 'filter'),
        continuation: 'token1',
      ),
    ).thenAnswer((_) async => throw Exception('offline'));
    controller.load(query: 'cats');
    await _settle();
    controller.paginate(query: 'cats');
    await _settle();
    expect(controller.state, isA<SearchResults$ErrorState>());
  });
}
