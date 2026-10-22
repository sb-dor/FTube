import 'package:control/control.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:youtube/src/feature/download_export/data/download_export_repository.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

part 'download_export_controller.freezed.dart';

/// Where a downloaded file was saved.
enum DownloadExportDestination { gallery, downloads }

@freezed
sealed class DownloadExportState with _$DownloadExportState {
  const DownloadExportState._();

  const factory DownloadExportState.initial() = DownloadExport$InitialState;

  /// Saving the download with id [fileId].
  const factory DownloadExportState.inProgress({required int fileId}) =
      DownloadExport$InProgressState;

  const factory DownloadExportState.error({
    required int fileId,
    required DownloadExportFailure failure,
    Object? error,
  }) = DownloadExport$ErrorState;

  const factory DownloadExportState.completed({
    required int fileId,
    required DownloadExportDestination destination,
  }) = DownloadExport$CompletedState;

  /// Whether the download with [id] is being saved right now.
  bool isSaving(int id) => switch (this) {
    DownloadExport$InProgressState(:final fileId) => fileId == id,
    _ => false,
  };
}

/// Saves downloaded files to the phone: videos to the gallery, audio to the Downloads folder.
final class DownloadExportController extends StateController<DownloadExportState>
    with DroppableControllerHandler {
  DownloadExportController({
    required this._downloadExportRepository,
    super.initialState = const DownloadExportState.initial(),
  });

  final IDownloadExportRepository _downloadExportRepository;

  void export(DownloadedFile file) => handle(
    () async {
      setState(DownloadExportState.inProgress(fileId: file.id));
      if (!file.exists) {
        throw const DownloadExportException(DownloadExportFailure.fileMissing);
      }
      if (file.isVideo) {
        await _downloadExportRepository.saveToGallery(file.path);
      } else {
        await _downloadExportRepository.saveToDownloads(file.path, title: file.title);
      }
      setState(
        DownloadExportState.completed(
          fileId: file.id,
          destination: file.isVideo
              ? DownloadExportDestination.gallery
              : DownloadExportDestination.downloads,
        ),
      );
    },
    error: (error, stackTrace) async => setState(
      DownloadExportState.error(
        fileId: file.id,
        failure: error is DownloadExportException ? error.failure : DownloadExportFailure.failed,
        error: error,
      ),
    ),
    name: 'export',
  );
}
