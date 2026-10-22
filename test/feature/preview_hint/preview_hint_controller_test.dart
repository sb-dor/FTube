import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/feature/preview_hint/controller/preview_hint_controller.dart';
import 'package:youtube/src/feature/preview_hint/data/preview_hint_repository.dart';

class _MockPreviewHintRepository extends Mock implements IPreviewHintRepository {}

void main() {
  late _MockPreviewHintRepository repository;
  late PreviewHintController controller;

  setUp(() {
    repository = _MockPreviewHintRepository();
    when(() => repository.markShown()).thenAnswer((_) async {});
    controller = PreviewHintController(previewHintRepository: repository);
  });

  tearDown(() => controller.dispose());

  /// Lets the controller finish every queued handler.
  Future<void> idle() async {
    do {
      await Future<void>.delayed(Duration.zero);
    } while (controller.isProcessing);
  }

  test('check is pending when the hint was never shown', () async {
    when(() => repository.isShown()).thenReturn(false);
    controller.check();
    await idle();

    expect(controller.state, isA<PreviewHint$PendingState>());
  });

  test('check is shown when the flag is already set', () async {
    when(() => repository.isShown()).thenReturn(true);
    controller.check();
    await idle();

    expect(controller.state, isA<PreviewHint$ShownState>());
  });

  test('check error sets the error state', () async {
    when(() => repository.isShown()).thenThrow(StateError('prefs'));
    controller.check();
    await idle();

    expect(controller.state, isA<PreviewHint$ErrorState>());
  });

  test('markShown persists the flag once and becomes shown', () async {
    when(() => repository.isShown()).thenReturn(false);
    controller
      ..check()
      ..markShown()
      ..markShown();
    await idle();

    expect(controller.state, isA<PreviewHint$ShownState>());
    verify(() => repository.markShown()).called(1);
  });

  test('markShown error sets the error state', () async {
    when(() => repository.isShown()).thenReturn(false);
    when(() => repository.markShown()).thenThrow(Exception('disk'));
    controller
      ..check()
      ..markShown();
    await idle();

    expect(controller.state, isA<PreviewHint$ErrorState>());
  });
}
