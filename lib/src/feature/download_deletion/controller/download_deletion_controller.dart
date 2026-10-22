import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/download_deletion/data/download_deletion_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

part 'download_deletion_controller.freezed.dart';

@freezed
sealed class DownloadDeletionState with _$DownloadDeletionState {
  const factory DownloadDeletionState.initial() = DownloadDeletion$InitialState;

  const factory DownloadDeletionState.inProgress() = DownloadDeletion$InProgressState;

  const factory DownloadDeletionState.error({Object? error}) = DownloadDeletion$ErrorState;

  const factory DownloadDeletionState.completed() = DownloadDeletion$CompletedState;
}

/// Deletes a downloaded file and its database row.
final class DownloadDeletionController extends StateController<DownloadDeletionState>
    with DroppableControllerHandler {
  DownloadDeletionController({
    required this._downloadDeletionRepository,
    super.initialState = const DownloadDeletionState.initial(),
  });

  final IDownloadDeletionRepository _downloadDeletionRepository;

  void delete(DownloadedFile file) => handle(
    () async {
      setState(const DownloadDeletionState.inProgress());
      await _downloadDeletionRepository.delete(file);
      setState(const DownloadDeletionState.completed());
    },
    error: (error, stackTrace) async => setState(DownloadDeletionState.error(error: error)),
    name: 'delete',
  );
}
