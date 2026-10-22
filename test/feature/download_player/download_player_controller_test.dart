import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/feature/download_player/controller/download_player_controller.dart';
import 'package:youtube/src/feature/download_player/data/download_player_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

class _MockDownloadPlayerRepository extends Mock implements IDownloadPlayerRepository {}

const _file = DownloadedFile(
  id: 1,
  title: 'Video',
  path: '/files/video.mp4',
  mediaType: DownloadMediaType.video,
  exists: true,
);

const _playing = DownloadPlayback(
  position: Duration(seconds: 3),
  duration: Duration(seconds: 60),
  isPlaying: true,
);

void main() {
  late _MockDownloadPlayerRepository repository;
  late StreamController<DownloadPlayback> playback;
  late DownloadPlayerController controller;

  setUpAll(() {
    registerFallbackValue(_file);
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    repository = _MockDownloadPlayerRepository();
    playback = StreamController<DownloadPlayback>();
    when(() => repository.open(any())).thenAnswer((_) async {});
    when(() => repository.playback).thenReturn(_playing);
    when(() => repository.video).thenReturn(null);
    when(repository.watchPlayback).thenAnswer((_) => playback.stream);
    when(repository.play).thenAnswer((_) async {});
    when(repository.pause).thenAnswer((_) async {});
    when(() => repository.seek(any())).thenAnswer((_) async {});
    when(repository.continueInBackground).thenAnswer((_) async {});
    when(repository.returnToForeground).thenAnswer((_) async {});
    when(repository.close).thenAnswer((_) async {});
    controller = DownloadPlayerController(downloadPlayerRepository: repository);
  });

  tearDown(() async {
    if (!controller.isDisposed) controller.dispose();
    unawaited(playback.close());
  });

  Future<void> open() async {
    controller.open(_file);
    await pumpEventQueue();
  }

  test('open plays the file and follows its playback', () async {
    await open();
    verify(() => repository.open(_file)).called(1);
    expect(
      controller.state,
      const DownloadPlayerState.completed(
        position: Duration(seconds: 3),
        duration: Duration(seconds: 60),
        isPlaying: true,
      ),
    );

    playback.add(
      const DownloadPlayback(
        position: Duration(seconds: 4),
        duration: Duration(seconds: 60),
        isPlaying: true,
      ),
    );
    await pumpEventQueue();
    expect(
      (controller.state as DownloadPlayer$CompletedState).position,
      const Duration(seconds: 4),
    );
  });

  test('a file that cannot be opened is an error', () async {
    when(() => repository.open(any())).thenThrow(StateError('codec'));
    await open();
    expect(controller.state, isA<DownloadPlayer$ErrorState>());
  });

  test('a playback error is an error', () async {
    await open();
    playback.addError(StateError('decoder'));
    await pumpEventQueue();
    expect(controller.state, isA<DownloadPlayer$ErrorState>());
  });

  test('togglePlay pauses and resumes', () async {
    await open();

    controller.togglePlay();
    await pumpEventQueue();
    verify(repository.pause).called(1);
    expect((controller.state as DownloadPlayer$CompletedState).isPlaying, isFalse);

    controller.togglePlay();
    await pumpEventQueue();
    verify(repository.play).called(1);
    expect((controller.state as DownloadPlayer$CompletedState).isPlaying, isTrue);
  });

  test('dragging the seek bar pauses, releasing seeks and resumes', () async {
    await open();

    controller.seekStart();
    await pumpEventQueue();
    verify(repository.pause).called(1);

    controller.seekEnd(const Duration(seconds: 30));
    await pumpEventQueue();
    verifyInOrder([() => repository.seek(const Duration(seconds: 30)), repository.play]);
    final state = controller.state as DownloadPlayer$CompletedState;
    expect(state.position, const Duration(seconds: 30));
    expect(state.isPlaying, isTrue);

    controller.seekEnd(const Duration(minutes: 5));
    await pumpEventQueue();
    verify(() => repository.seek(const Duration(seconds: 60))).called(1);
  });

  test('a playing video continues in the background and comes back', () async {
    await open();

    controller.appPaused();
    await pumpEventQueue();
    verify(repository.continueInBackground).called(1);

    controller.appResumed();
    await pumpEventQueue();
    verify(repository.returnToForeground).called(1);
  });

  test('nothing continues in the background while paused', () async {
    await open();
    controller.pause();
    await pumpEventQueue();

    controller.appPaused();
    await pumpEventQueue();
    verifyNever(repository.continueInBackground);
  });

  test('a failed hand-over to the background keeps the player usable', () async {
    when(repository.continueInBackground).thenThrow(StateError('audio'));
    await open();

    controller.appPaused();
    await pumpEventQueue();
    expect(controller.state, isA<DownloadPlayer$CompletedState>());
  });

  test('dispose stops playback', () async {
    await open();
    controller.dispose();
    await pumpEventQueue();
    verify(repository.close).called(1);
    expect(playback.hasListener, isFalse);
  });
}
