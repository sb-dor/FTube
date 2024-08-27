import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

class JustAudioBackgroundHelper {
  Future<void> initJustAudioBackground() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: "com.ryanheise.bg_demo.channel.audio",
      androidNotificationChannelName: "Audio playback",
      androidNotificationOngoing: true,
    );
  }

  AudioPlayer? _player;

  Duration? lastSavedDuration;

  void setNewAudioSources(
    List<MediaItem> items,
    Duration duration,
  ) async {
    _player ??= AudioPlayer();
    final playlist = ConcatenatingAudioSource(
      children: [
        ...items
            .map(
              (e) => AudioSource.uri(
                // I will put url of audio in id
                Uri.parse(e.id),
                tag: e,
              ),
            )
            .toList(),
      ],
    );
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    _player?.playbackEventStream.listen(
      (event) {
        //
      },
      onError: (Object e, StackTrace stackTrace) {
        debugPrint('A stream error occurred: $e');
      },
    );

    _player?.positionStream.listen(
      (event) {
        lastSavedDuration = event;
      },
    );

    await _player?.setAudioSource(playlist);

    await _player?.seek(duration);

    await _player?.play();
  }

  void dispose() async {
    lastSavedDuration = null;
    await _player?.stop();
  }
}

// all about running audio in background you can find here:
// https://pub.dev/packages/audio_service
// https://pub.dev/packages/just_audio
// https://suragch.medium.com/background-audio-in-flutter-with-audio-service-and-just-audio-3cce17b4a7d
// https://pub.dev/packages/just_audio_background/example
