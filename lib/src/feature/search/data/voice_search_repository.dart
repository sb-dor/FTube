import 'dart:async';

import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:youtube/src/feature/search/models/voice_search_failure.dart';

abstract interface class IVoiceSearchRepository {
  /// Prepares speech recognition, asking for permission the first time.
  ///
  /// Throws [VoiceSearchException] when voice search cannot be used.
  Future<void> initialize();

  /// Listens to the microphone. Every event is the whole phrase recognized so far; the stream
  /// completes when listening ends and fails with [VoiceSearchException] when recognition fails.
  Stream<String> listen();

  /// Ends the current [listen] early; its stream completes with the words heard so far.
  Future<void> stop();

  /// Ends the current [listen] and discards it.
  Future<void> cancel();
}

final class VoiceSearchRepositoryImpl implements IVoiceSearchRepository {
  VoiceSearchRepositoryImpl({SpeechToText? speechToText})
    : _speech = speechToText ?? SpeechToText();

  static const _permissionErrors = {'error_permission', 'error_insufficient_permissions'};

  /// Errors that only mean nothing (more) was heard: the session ends with what it has.
  static const _silenceErrors = {'error_no_match', 'error_speech_timeout'};

  /// How long [stop] waits for the recognizer's final result before ending the session itself.
  static const _stopTimeout = Duration(seconds: 3);

  final SpeechToText _speech;
  StreamController<String>? _session;
  Timer? _stopTimer;

  @override
  Future<void> initialize() async {
    final bool ready;
    try {
      ready = await _speech.initialize();
    } on Object catch (error) {
      throw VoiceSearchException(VoiceSearchFailure.unavailable, '$error');
    }
    if (ready) return;
    final permitted = await _speech.hasPermission.catchError((Object _) => false);
    throw VoiceSearchException(
      permitted ? VoiceSearchFailure.unavailable : VoiceSearchFailure.permissionDenied,
    );
  }

  @override
  Stream<String> listen() {
    _finish(_session);
    final session = StreamController<String>();
    _session = session;
    session
      ..onListen = () {
        _start(session).ignore();
      }
      ..onCancel = () {
        // Also called after the done event; only a subscriber leaving early cancels speech.
        if (session.isClosed) return;
        _finish(session);
        _speech.cancel().ignore();
      };
    return session.stream;
  }

  Future<void> _start(StreamController<String> session) async {
    _speech
      ..statusListener = (status) {
        if (status == SpeechToText.doneStatus) _finish(session);
      }
      ..errorListener = (error) => _onError(session, error);
    try {
      await _speech.listen(
        onResult: (result) {
          if (session.isClosed) return;
          session.add(result.recognizedWords);
          if (result.finalResult) _finish(session);
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.search,
          cancelOnError: true,
          pauseFor: const Duration(seconds: 3),
          listenFor: const Duration(seconds: 30),
        ),
      );
    } on Object catch (error, stackTrace) {
      if (session.isClosed) return;
      session.addError(VoiceSearchException(VoiceSearchFailure.failed, '$error'), stackTrace);
      _finish(session);
    }
  }

  void _onError(StreamController<String> session, SpeechRecognitionError error) {
    if (session.isClosed) return;
    if (_silenceErrors.contains(error.errorMsg)) return _finish(session);
    if (!error.permanent) return;
    final failure = _permissionErrors.contains(error.errorMsg)
        ? VoiceSearchFailure.permissionDenied
        : VoiceSearchFailure.failed;
    session.addError(VoiceSearchException(failure, error.errorMsg));
    _finish(session);
  }

  @override
  Future<void> stop() async {
    final session = _session;
    if (session == null || session.isClosed) return;
    _stopTimer?.cancel();
    _stopTimer = Timer(_stopTimeout, () => _finish(session));
    await _speech.stop();
  }

  @override
  Future<void> cancel() async {
    final session = _session;
    if (session == null || session.isClosed) return;
    _finish(session);
    await _speech.cancel();
  }

  void _finish(StreamController<String>? session) {
    if (session == null || session.isClosed) return;
    if (identical(_session, session)) {
      _stopTimer?.cancel();
      _session = null;
    }
    session.close().ignore();
  }
}
