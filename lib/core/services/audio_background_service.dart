import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

class JustAudioBackgroundHelper {
  static JustAudioBackgroundHelper? _instance;

  static JustAudioBackgroundHelper get instance => _instance ??= JustAudioBackgroundHelper._();

  JustAudioBackgroundHelper._();

  Future<void> initJustAudioBackground() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: "com.ryanheise.bg_demo.channel.audio",
      androidNotificationChannelName: "Audio playback",
      androidNotificationOngoing: true,
    );
  }

  AudioPlayer? player;

  Duration? lastSavedDuration;

  void setNewAudioSources({
    List<MediaItem>? items,
    Duration? duration,
    List<MediaItem>? localFilesPaths,
  }) async {
    player ??= AudioPlayer();
    final playlist = ConcatenatingAudioSource(
      children: [
        if (items != null)
          ...items.map(
            (e) => AudioSource.uri(
              // I will put url of audio in id
              Uri.parse(e.id),
              tag: e,
            ),
          ),
        if (localFilesPaths != null)
          ...localFilesPaths.map(
            (e) => AudioSource.uri(
              Uri.file(e.id),
              tag: e,
            ),
          ),
      ],
    );
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    player?.playbackEventStream.listen(
      (event) {
        //
      },
      onError: (Object e, StackTrace stackTrace) {
        // // debugPrint'A stream error occurred: $e');
      },
    );

    player?.positionStream.listen(
      (event) {
        lastSavedDuration = event;
      },
    );

    await player?.setAudioSource(playlist);

    await player?.seek(duration);

    await player?.setLoopMode(LoopMode.one);

    await player?.play();
  }

  Future<void> stopPlayer() async {
    lastSavedDuration = null;
    await player?.stop();
  }

  Future<void> stopAndDispose() async {
    await stopPlayer();
    await player?.dispose();
  }
}

// all about running audio in background you can find here:
// https://pub.dev/packages/audio_service
// https://pub.dev/packages/just_audio
// https://suragch.medium.com/background-audio-in-flutter-with-audio-service-and-just-audio-3cce17b4a7d
// https://pub.dev/packages/just_audio_background/example
