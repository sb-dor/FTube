import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/feature/search/controller/search_suggestions_controller.dart';
import 'package:youtube/src/feature/search/data/search_suggestions_repository.dart';

class _MockSuggestionsRepository extends Mock implements ISearchSuggestionsRepository {}

const _debounce = Duration(milliseconds: 20);

/// Waits past the debounce so the pending request is sent.
Future<void> _afterDebounce() => Future<void>.delayed(_debounce * 2);

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockSuggestionsRepository repository;
  late SearchSuggestionsController controller;
  late List<SearchSuggestionsState> states;

  setUp(() {
    repository = _MockSuggestionsRepository();
    controller = SearchSuggestionsController(
      suggestionsRepository: repository,
      debounce: _debounce,
    );
    states = [];
    controller.addListener(() => states.add(controller.state));
  });

  tearDown(() => controller.dispose());

  test('debounces keystrokes and fetches only the last text', () async {
    when(() => repository.suggestions('cat')).thenAnswer((_) async => ['cat videos', 'cats']);

    controller
      ..request('c')
      ..request('ca')
      ..request(' cat ');
    await _afterDebounce();

    verify(() => repository.suggestions('cat')).called(1);
    verifyNoMoreInteractions(repository);
    expect(
      controller.state,
      const SearchSuggestionsState.completed(query: 'cat', suggestions: ['cat videos', 'cats']),
    );
    expect(controller.state.items, ['cat videos', 'cats']);
  });

  test('a late response for an older keystroke never overwrites the newer one', () async {
    final older = Completer<List<String>>();
    final newer = Completer<List<String>>();
    when(() => repository.suggestions('ca')).thenAnswer((_) => older.future);
    when(() => repository.suggestions('cat')).thenAnswer((_) => newer.future);

    controller.request('ca');
    await _afterDebounce(); // 'ca' is in flight
    controller.request('cat');
    await _afterDebounce(); // 'cat' is queued behind it

    older.complete(['ca old']);
    await _settle();
    newer.complete(['cat new']);
    await _settle();

    expect(controller.state.items, ['cat new']);
    expect(
      states.whereType<SearchSuggestions$CompletedState>().map((s) => s.query),
      isNot(contains('ca')),
    );
  });

  test('a response that arrives after a newer request was made is dropped', () async {
    final older = Completer<List<String>>();
    when(() => repository.suggestions('ca')).thenAnswer((_) => older.future);
    when(() => repository.suggestions('cat')).thenAnswer((_) async => ['cat new']);

    controller.request('ca');
    await _afterDebounce();
    controller.request('cat'); // still debouncing when the old answer lands
    older.complete(['ca old']);
    await _settle();
    expect(controller.state, isA<SearchSuggestions$InitialState>());

    await _afterDebounce();
    expect(controller.state.items, ['cat new']);
  });

  test('requests superseded while queued are skipped without a network call', () async {
    final first = Completer<List<String>>();
    when(() => repository.suggestions('a')).thenAnswer((_) => first.future);
    when(() => repository.suggestions('abc')).thenAnswer((_) async => ['abc']);

    controller.request('a');
    await _afterDebounce();
    controller.request('ab');
    await _afterDebounce(); // 'ab' queued
    controller.request('abc');
    await _afterDebounce(); // 'abc' queued
    first.complete(['a']);
    await _settle();
    await _settle();

    verifyNever(() => repository.suggestions('ab'));
    expect(controller.state.items, ['abc']);
  });

  test('errors just mean no suggestions', () async {
    when(() => repository.suggestions('cat')).thenAnswer((_) async => throw Exception('offline'));

    controller.request('cat');
    await _afterDebounce();

    expect(controller.state, const SearchSuggestionsState.completed(query: 'cat', suggestions: []));
    expect(controller.state.items, isEmpty);
  });

  test('clear drops the in-flight request and empties the suggestions', () async {
    final pending = Completer<List<String>>();
    when(() => repository.suggestions('cat')).thenAnswer((_) => pending.future);

    controller.request('cat');
    await _afterDebounce();
    controller.clear();
    pending.complete(['cats']);
    await _settle();
    await _settle();

    expect(controller.state, isA<SearchSuggestions$InitialState>());
  });

  test('blank text clears instead of fetching', () async {
    when(() => repository.suggestions('cat')).thenAnswer((_) async => ['cats']);
    controller.request('cat');
    await _afterDebounce();

    controller.request('   ');
    await _afterDebounce();

    verify(() => repository.suggestions('cat')).called(1);
    verifyNoMoreInteractions(repository);
    expect(controller.state, isA<SearchSuggestions$InitialState>());
  });
}
