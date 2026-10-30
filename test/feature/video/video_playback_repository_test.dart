import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/feature/video/data/video_playback_repository.dart';

class _MockVideoPlayerController extends Mock implements VideoPlayerController {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

final _refused = StreamSource(url: Uri.parse('https://example.com/refused.mp4'), client: 'WEB');
final _served = StreamSource(url: Uri.parse('https://example.com/served.mp4'), client: 'IOS');

_MockVideoPlayerController _player({required bool plays}) {
  final player = _MockVideoPlayerController();
  when(player.initialize)
      .thenAnswer((_) => plays ? Future<void>.value() : Future<void>.error(Exception('403')));
  when(() => player.seekTo(any())).thenAnswer((_) async {});
  when(player.play).thenAnswer((_) async {});
  when(player.dispose).thenAnswer((_) async {});
  when(() => player.value).thenReturn(
    const VideoPlayerValue(
      duration: Duration(minutes: 3),
      position: Duration(seconds: 7),
      isInitialized: true,
    ),
  );
  return player;
}

void main() {
  setUpAll(() => registerFallbackValue(Duration.zero));

  late Map<StreamSource, _MockVideoPlayerController> players;
  late VideoPlaybackRepositoryImpl repository;

  setUp(() {
    players = {_refused: _player(plays: false), _served: _player(plays: true)};
    repository = VideoPlaybackRepositoryImpl(
      backgroundAudio: BackgroundAudio(player: _MockAudioPlayer()),
      createController: (source) => players[source]!,
    );
  });

  test('falls back to the next source when one is refused', () async {
    await repository.open([_refused, _served], startAt: const Duration(seconds: 30));

    expect(repository.video, same(players[_served]));
    expect(repository.source, _served);
    expect(repository.position, const Duration(seconds: 7));
    verify(players[_refused]!.dispose).called(1);
    verify(() => players[_served]!.seekTo(const Duration(seconds: 30))).called(1);
    verify(players[_served]!.play).called(1);
  });

  test('throws when no source plays', () async {
    await expectLater(repository.open([_refused]), throwsStateError);
    expect(repository.video, isNull);
  });

  test('opening again releases the previous player', () async {
    await repository.open([_served]);
    final first = repository.video!;
    players[_served] = _player(plays: true);
    await repository.open([_served]);

    verify(first.dispose).called(1);
    expect(repository.video, isNot(same(first)));
  });

  test('close releases the player', () async {
    await repository.open([_served]);
    final player = repository.video!;
    await repository.close();

    verify(player.dispose).called(1);
    expect(repository.video, isNull);
  });
}
