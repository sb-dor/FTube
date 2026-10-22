import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/feature/search/controller/voice_search_controller.dart';
import 'package:youtube/src/feature/search/data/voice_search_repository.dart';
import 'package:youtube/src/feature/search/models/voice_search_failure.dart';

class _MockVoiceSearchRepository extends Mock implements IVoiceSearchRepository {}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  late _MockVoiceSearchRepository repository;
  late VoiceSearchController controller;
  late StreamController<String> words;

  setUp(() {
    repository = _MockVoiceSearchRepository();
    words = StreamController<String>();
    when(() => repository.initialize()).thenAnswer((_) async {});
    when(() => repository.listen()).thenAnswer((_) => words.stream);
    when(() => repository.stop()).thenAnswer((_) async {});
    when(() => repository.cancel()).thenAnswer((_) async {});
    controller = VoiceSearchController(voiceSearchRepository: repository);
  });

  tearDown(() {
    controller.dispose();
    // Never awaited: closing a stream nobody listened to does not complete.
    words.close().ignore();
  });

  test('reports the words while listening and completes with the last phrase', () async {
    controller.start();
    expect(controller.state, const VoiceSearchState.listening());

    await _settle();
    words.add('funny');
    await _settle();
    expect(controller.state, const VoiceSearchState.listening(words: 'funny'));

    words.add('funny cats ');
    await words.close();
    await _settle();
    expect(controller.state, const VoiceSearchState.completed(words: 'funny cats'));
  });

  test('completes with no words when nothing was heard', () async {
    controller.start();
    await _settle();
    await words.close();
    await _settle();
    expect(controller.state, const VoiceSearchState.completed(words: ''));
  });

  test('a denied permission ends in the permissionDenied error', () async {
    when(() => repository.initialize()).thenAnswer(
      (_) async => throw const VoiceSearchException(VoiceSearchFailure.permissionDenied),
    );
    controller.start();
    await _settle();
    expect(
      controller.state,
      const VoiceSearchState.error(failure: VoiceSearchFailure.permissionDenied),
    );
    verifyNever(() => repository.listen());
  });

  test('a missing recognizer ends in the unavailable error', () async {
    when(() => repository.initialize())
        .thenAnswer((_) async => throw const VoiceSearchException(VoiceSearchFailure.unavailable));
    controller.start();
    await _settle();
    expect(controller.state, const VoiceSearchState.error(failure: VoiceSearchFailure.unavailable));
  });

  test('unexpected recognition errors end in the failed error', () async {
    controller.start();
    await _settle();
    words.addError(StateError('boom'));
    await _settle();
    expect(controller.state, const VoiceSearchState.error(failure: VoiceSearchFailure.failed));
  });

  test('stop asks the recognizer to finish only while listening', () async {
    controller.stop();
    verifyNever(() => repository.stop());

    controller.start();
    await _settle();
    controller.stop();
    verify(() => repository.stop()).called(1);
  });

  test('stop during initialization never starts listening', () async {
    final initialized = Completer<void>();
    when(() => repository.initialize()).thenAnswer((_) => initialized.future);

    controller
      ..start()
      ..stop();
    initialized.complete();
    await _settle();

    expect(controller.state, const VoiceSearchState.completed(words: ''));
    verifyNever(() => repository.listen());
  });

  test('a second start while listening is dropped', () async {
    controller.start();
    await _settle();
    controller.start();
    await _settle();
    verify(() => repository.initialize()).called(1);
  });
}
