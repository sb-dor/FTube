import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/preview_hint/data/preview_hint_repository.dart';

part 'preview_hint_controller.freezed.dart';

@freezed
sealed class PreviewHintState with _$PreviewHintState {
  const PreviewHintState._();

  const factory PreviewHintState.initial() = PreviewHint$InitialState;

  /// The user has not seen the hint yet: it should be shown.
  const factory PreviewHintState.pending() = PreviewHint$PendingState;

  /// The hint was shown and dismissed, now or on an earlier run.
  const factory PreviewHintState.shown() = PreviewHint$ShownState;

  const factory PreviewHintState.error({Object? error}) = PreviewHint$ErrorState;
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
    () async => setState(
      _previewHintRepository.isShown()
          ? const PreviewHintState.shown()
          : const PreviewHintState.pending(),
    ),
    error: (error, stackTrace) async => setState(PreviewHintState.error(error: error)),
    name: 'check',
  );

  void markShown() => handle(
    () async {
      if (state is PreviewHint$ShownState) return;
      await _previewHintRepository.markShown();
      setState(const PreviewHintState.shown());
    },
    error: (error, stackTrace) async => setState(PreviewHintState.error(error: error)),
    name: 'markShown',
  );
}
