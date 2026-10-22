import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/history_deletion/controller/history_deletion_controller.dart';
import 'package:youtube/src/feature/history_deletion/data/history_deletion_repository.dart';

class _MockHistoryDeletionRepository extends Mock implements IHistoryDeletionRepository {}

bool _settled(HistoryDeletionState state) =>
    state is HistoryDeletion$CompletedState || state is HistoryDeletion$ErrorState;

void main() {
  late _MockHistoryDeletionRepository repository;
  late HistoryDeletionController controller;

  setUp(() {
    repository = _MockHistoryDeletionRepository();
    controller = HistoryDeletionController(historyDeletionRepository: repository);
  });
  tearDown(() => controller.dispose());

  test('remove deletes one video', () async {
    when(() => repository.remove('a')).thenAnswer((_) async {});
    controller.remove('a');
    await controller.waitFor(_settled);
    expect(controller.state, const HistoryDeletionState.completed());
    verify(() => repository.remove('a')).called(1);
  });

  test('clear clears the history', () async {
    when(() => repository.clear()).thenAnswer((_) async {});
    controller.clear();
    await controller.waitFor(_settled);
    expect(controller.state, const HistoryDeletionState.completed());
    verify(() => repository.clear()).called(1);
  });

  test('a failure moves to error', () async {
    when(() => repository.clear()).thenThrow(StateError('db'));
    controller.clear();
    await controller.waitFor(_settled);
    expect(controller.state, isA<HistoryDeletion$ErrorState>());
  });

  test('taps while deleting are dropped', () async {
    when(() => repository.remove(any())).thenAnswer((_) async {});
    controller
      ..remove('a')
      ..remove('b');
    await controller.waitFor(_settled);
    verify(() => repository.remove('a')).called(1);
    verifyNever(() => repository.remove('b'));
  });
}
