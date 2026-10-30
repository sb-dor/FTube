import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/feature/video/controller/video_playback_controller.dart';
import 'package:youtube/src/feature/video/data/video_playback_repository.dart';

class _MockVideoPlaybackRepository extends Mock implements IVideoPlaybackRepository {}

class _MockVideoPlayerController extends Mock implements VideoPlayerController {}

final _low = StreamSource(url: Uri.parse('https://example.com/360.mp4'), client: 'ANDROID_VR');
final _high = StreamSource(url: Uri.parse('https://example.com/720.mp4'), client: 'IOS');
const _item = MediaItem(id: 'abcdefghijk', title: 'Song');

void main() {
  late _MockVideoPlaybackRepository repository;
  late _MockVideoPlayerController video;
  late StreamController<bool> playing;
  late VideoPlaybackController controller;

  setUpAll(() {
    registerFallbackValue(<StreamSource>[]);
    registerFallbackValue(_item);
    registerFallbackValue(Duration.zero);
  });

  setUp(() {
    repository = _MockVideoPlaybackRepository();
    video = _MockVideoPlayerController();
    playing = StreamController<bool>.broadcast();
    when(() => video.value).thenReturn(
      const VideoPlayerValue(duration: Duration(minutes: 3), isInitialized: true, isPlaying: true),
    );
    when(() => repository.open(any(), startAt: any(named: 'startAt'))).thenAnswer((_) async {});
    when(() => repository.video).thenReturn(video);
    when(() => repository.source).thenReturn(_low);
    when(() => repository.position).thenReturn(const Duration(seconds: 42));
    when(repository.watchPlaying).thenAnswer((_) => playing.stream);
    when(repository.play).thenAnswer((_) async {});
    when(repository.pause).thenAnswer((_) async {});
    when(
      () => repository.continueInBackground(
        item: any(named: 'item'),
        audio: any(named: 'audio'),
      ),
    ).thenAnswer((_) async {});
    when(repository.returnToForeground).thenAnswer((_) async {});
    when(repository.close).thenAnswer((_) async {});
    controller = VideoPlaybackController(videoPlaybackRepository: repository);
  });

  tearDown(() {
    if (!controller.isDisposed) controller.dispose();
    unawaited(playing.close());
  });

  Future<void> open() async {
    controller.open([_low, _high], startAt: const Duration(seconds: 5));
    await pumpEventQueue();
  }

  test('open plays a source and follows whether it plays', () async {
    await open();
    verify(() => repository.open([_low, _high], startAt: const Duration(seconds: 5))).called(1);
    expect(
      controller.state,
      VideoPlaybackState.completed(video: video, source: _low, isPlaying: true),
    );

    playing.add(false);
    await pumpEventQueue();
    expect((controller.state as VideoPlayback$CompletedState).isPlaying, isFalse);
  });

  test('open fails when no source plays', () async {
    when(() => repository.open(any(), startAt: any(named: 'startAt')))
        .thenThrow(StateError('no source'));
    await open();
    expect(controller.state, isA<VideoPlayback$ErrorState>());
  });

  test('switching quality continues from the current position', () async {
    await open();
    when(() => repository.source).thenReturn(_high);
    controller.switchSources([_high]);
    await pumpEventQueue();
    verify(() => repository.open([_high], startAt: const Duration(seconds: 42))).called(1);
    expect((controller.state as VideoPlayback$CompletedState).source, _high);
  });

  test('togglePlay pauses a playing video and plays a paused one', () async {
    await open();
    controller.togglePlay();
    await pumpEventQueue();
    verify(repository.pause).called(1);
    expect((controller.state as VideoPlayback$CompletedState).isPlaying, isFalse);

    controller.togglePlay();
    await pumpEventQueue();
    verify(repository.play).called(1);
    expect((controller.state as VideoPlayback$CompletedState).isPlaying, isTrue);
  });

  test('togglePlay does nothing before the video opens', () async {
    controller.togglePlay();
    await pumpEventQueue();
    verifyNever(repository.play);
    verifyNever(repository.pause);
  });

  test('hands the sound to the background and back', () async {
    await open();
    final audio = StreamSource(url: Uri.parse('https://example.com/audio.m4a'), client: 'IOS');
    controller.appPaused(item: _item, audio: audio);
    await pumpEventQueue();
    verify(() => repository.continueInBackground(item: _item, audio: audio)).called(1);

    controller.appResumed();
    await pumpEventQueue();
    verify(repository.returnToForeground).called(1);
  });

  test('dispose releases the player', () async {
    await open();
    controller.dispose();
    verify(repository.close).called(1);
  });
}
