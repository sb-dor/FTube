import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/history_deletion/data/history_deletion_repository.dart';

part 'history_deletion_controller.freezed.dart';

@freezed
sealed class HistoryDeletionState with _$HistoryDeletionState {
  const HistoryDeletionState._();

  const factory HistoryDeletionState.initial() = HistoryDeletion$InitialState;

  const factory HistoryDeletionState.inProgress() = HistoryDeletion$InProgressState;

  const factory HistoryDeletionState.error({Object? error}) = HistoryDeletion$ErrorState;

  const factory HistoryDeletionState.completed() = HistoryDeletion$CompletedState;
}

/// Removes one video from the watch history, or clears it.
final class HistoryDeletionController extends StateController<HistoryDeletionState>
    with DroppableControllerHandler {
  HistoryDeletionController({
    required this._historyDeletionRepository,
    super.initialState = const HistoryDeletionState.initial(),
  });

  final IHistoryDeletionRepository _historyDeletionRepository;

  void remove(String videoId) => handle(
    () async {
      setState(const HistoryDeletionState.inProgress());
      await _historyDeletionRepository.remove(videoId);
      setState(const HistoryDeletionState.completed());
    },
    error: (error, stackTrace) async => setState(HistoryDeletionState.error(error: error)),
    name: 'remove',
  );

  void clear() => handle(
    () async {
      setState(const HistoryDeletionState.inProgress());
      await _historyDeletionRepository.clear();
      setState(const HistoryDeletionState.completed());
    },
    error: (error, stackTrace) async => setState(HistoryDeletionState.error(error: error)),
    name: 'clear',
  );
}
