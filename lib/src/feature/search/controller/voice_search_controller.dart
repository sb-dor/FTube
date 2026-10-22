import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/search/data/voice_search_repository.dart';
import 'package:youtube/src/feature/search/models/voice_search_failure.dart';

part 'voice_search_controller.freezed.dart';

@freezed
sealed class VoiceSearchState with _$VoiceSearchState {
  const VoiceSearchState._();

  const factory VoiceSearchState.initial() = VoiceSearch$InitialState;

  /// Listening; [words] is the phrase recognized so far.
  const factory VoiceSearchState.listening({@Default('') String words}) =
      VoiceSearch$ListeningState;

  const factory VoiceSearchState.error({required VoiceSearchFailure failure}) =
      VoiceSearch$ErrorState;

  /// Listening ended; [words] is the recognized phrase, empty when nothing was heard.
  const factory VoiceSearchState.completed({required String words}) = VoiceSearch$CompletedState;
}

/// Turns speech into a search query.
///
/// [start] is droppable so repeated taps never open a second session; [stop] bypasses the
/// handler on purpose because it must reach the session [start] is still running.
final class VoiceSearchController extends StateController<VoiceSearchState>
    with DroppableControllerHandler {
  VoiceSearchController({
    required this._voiceSearchRepository,
    super.initialState = const VoiceSearchState.initial(),
  });

  final IVoiceSearchRepository _voiceSearchRepository;

  /// Set by [stop] so a session stopped while still initializing never starts listening.
  bool _stopRequested = false;

  void start() => handle(
    () async {
      _stopRequested = false;
      setState(const VoiceSearchState.listening());
      await _voiceSearchRepository.initialize();
      if (_stopRequested) return setState(const VoiceSearchState.completed(words: ''));
      var words = '';
      await for (final recognized in _voiceSearchRepository.listen()) {
        words = recognized;
        setState(VoiceSearchState.listening(words: recognized));
      }
      setState(VoiceSearchState.completed(words: words.trim()));
    },
    error: (error, stackTrace) async => setState(
      VoiceSearchState.error(
        failure: error is VoiceSearchException ? error.failure : VoiceSearchFailure.failed,
      ),
    ),
    name: 'start',
  );

  /// Stops listening; [start] then completes with the words heard so far.
  void stop() {
    if (state is! VoiceSearch$ListeningState) return;
    _stopRequested = true;
    _voiceSearchRepository.stop().catchError(onError);
  }

  @override
  void dispose() {
    _voiceSearchRepository.cancel().ignore();
    super.dispose();
  }
}
