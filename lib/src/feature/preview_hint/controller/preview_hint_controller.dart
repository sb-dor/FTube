import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/preview_hint/data/preview_hint_repository.dart';

part 'preview_hint_controller.freezed.dart';

@freezed
sealed class PreviewHintState with _$PreviewHintState {
  const PreviewHintState._();

  const factory PreviewHintState.initial() = PreviewHint$InitialState;

  const factory PreviewHintState.error({Object? error}) = PreviewHint$ErrorState;

  /// The persisted flag is known. [isShown]: the hint was shown and dismissed, now or on an
  /// earlier run; otherwise the user has not seen it yet and it should be shown.
  const factory PreviewHintState.completed({required bool isShown}) = PreviewHint$CompletedState;
}

/// Decides whether the first-run hold-to-preview hint is shown and remembers its dismissal.
///
/// Sequential, so a [markShown] issued while [check] is still running waits for it instead of
/// being dropped.
final class PreviewHintController extends StateController<PreviewHintState>
    with SequentialControllerHandler {
  PreviewHintController({
    required this._previewHintRepository,
    super.initialState = const PreviewHintState.initial(),
  });

  final IPreviewHintRepository _previewHintRepository;

  void check() => handle(
    () async => setState(PreviewHintState.completed(isShown: _previewHintRepository.isShown())),
    error: (error, stackTrace) async => setState(PreviewHintState.error(error: error)),
    name: 'check',
  );

  void markShown() => handle(
    () async {
      if (state case PreviewHint$CompletedState(isShown: true)) return;
      await _previewHintRepository.markShown();
      setState(const PreviewHintState.completed(isShown: true));
    },
    error: (error, stackTrace) async => setState(PreviewHintState.error(error: error)),
    name: 'markShown',
  );
}
