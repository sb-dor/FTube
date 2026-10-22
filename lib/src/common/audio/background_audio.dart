import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

export 'package:just_audio_background/just_audio_background.dart' show MediaItem;

/// The app's single audio player with a media notification and lock-screen controls.
///
/// `just_audio_background` supports one player per app, so every feature that plays audio
/// (background playback of a video, downloaded files) goes through this instance.
final class BackgroundAudio {
  BackgroundAudio({required this.player});

  /// Registers the media notification channel; call once before creating the player.
  static Future<void> initialize() => JustAudioBackground.init(
    androidNotificationChannelId: 'com.bdaynabday.ftube.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  final AudioPlayer player;

  /// Starts playing [uri] described by [item] from [position]. Completes once playback has
  /// started (just_audio's own `play()` only completes when playback stops).
  Future<void> play(
    Uri uri, {
    required MediaItem item,
    Map<String, String>? headers,
    Duration position = Duration.zero,
    LoopMode loopMode = LoopMode.off,
  }) async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    await player.setAudioSource(
      AudioSource.uri(uri, headers: headers, tag: item),
      initialPosition: position,
    );
    await player.setLoopMode(loopMode);
    player.play().ignore();
  }

  Future<void> stop() => player.stop();
}
