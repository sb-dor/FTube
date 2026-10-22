import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/src/feature/search/controller/search_history_controller.dart';
import 'package:youtube/src/feature/search/data/search_history_repository.dart';

class _MockHistoryRepository extends Mock implements ISearchHistoryRepository {}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  group('SearchHistoryController', () {
    late _MockHistoryRepository repository;
    late SearchHistoryController controller;

    /// What the mock repository currently stores.
    late List<String> stored;

    setUp(() {
      stored = [];
      repository = _MockHistoryRepository();
      when(() => repository.read()).thenAnswer((_) async => List.of(stored));
      when(() => repository.write(any())).thenAnswer((invocation) async {
        stored = List.of(invocation.positionalArguments.first as List<String>);
      });
      controller = SearchHistoryController(historyRepository: repository);
    });

    tearDown(() => controller.dispose());

    test('load shows the saved queries', () async {
      stored = ['dogs', 'cats'];
      controller.load();
      await _settle();
      expect(controller.state, const SearchHistoryState.completed(queries: ['dogs', 'cats']));
      expect(controller.state.items, ['dogs', 'cats']);
    });

    test('a failed load ends in the error state with no items', () async {
      when(() => repository.read()).thenAnswer((_) async => throw Exception('disk'));
      controller.load();
      await _settle();
      expect(controller.state, isA<SearchHistory$ErrorState>());
      expect(controller.state.items, isEmpty);
    });

    test('add puts the trimmed query first and saves it', () async {
      stored = ['dogs'];
      controller.add('  cats  ');
      await _settle();
      expect(stored, ['cats', 'dogs']);
      expect(controller.state.items, ['cats', 'dogs']);
    });

    test('add replaces an entry that differs only in case and moves it to the top', () async {
      stored = ['dogs', 'Cats', 'birds'];
      controller.add('cATS');
      await _settle();
      expect(stored, ['cATS', 'dogs', 'birds']);
    });

    test('add keeps at most 30 entries, dropping the oldest', () async {
      stored = [for (var i = 0; i < 30; i++) 'query $i'];
      controller.add('new');
      await _settle();
      expect(stored, hasLength(SearchHistoryController.maxEntries));
      expect(stored.first, 'new');
      expect(stored.last, 'query 28');
    });

    test('add ignores blank queries', () async {
      controller.add('   ');
      await _settle();
      verifyNever(() => repository.write(any()));
      expect(controller.state, isA<SearchHistory$InitialState>());
    });

    test('remove deletes the entry ignoring case', () async {
      stored = ['dogs', 'Cats'];
      controller.remove('cats');
      await _settle();
      expect(stored, ['dogs']);
      expect(controller.state.items, ['dogs']);
    });

    test('remove of an unknown query writes nothing', () async {
      stored = ['dogs'];
      controller.remove('cats');
      await _settle();
      verifyNever(() => repository.write(any()));
    });

    test('quick successive changes are all applied in order', () async {
      stored = ['old'];
      controller
        ..load()
        ..add('one')
        ..add('two')
        ..remove('old')
        ..add('ONE');
      await _settle();
      expect(stored, ['ONE', 'two']);
      expect(controller.state.items, ['ONE', 'two']);
    });

    test('a failed save keeps the shown history', () async {
      stored = ['dogs'];
      controller.load();
      await _settle();
      when(() => repository.write(any())).thenAnswer((_) async => throw Exception('disk'));
      controller.add('cats');
      await _settle();
      expect(controller.state.items, ['dogs']);
    });
  });

  group('SearchHistoryRepositoryImpl', () {
    test('persists the list under search_history across instances', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await SearchHistoryRepositoryImpl(sharedPreferences: prefs).write(['cats', 'dogs']);

      expect(prefs.getStringList('search_history'), ['cats', 'dogs']);
      expect(await SearchHistoryRepositoryImpl(sharedPreferences: prefs).read(), ['cats', 'dogs']);
    });

    test('reads an empty list when nothing was saved', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(await SearchHistoryRepositoryImpl(sharedPreferences: prefs).read(), isEmpty);
    });
  });
}
