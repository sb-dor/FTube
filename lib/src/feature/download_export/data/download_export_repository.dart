import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:youtube/src/common/download/device_media_store.dart';
import 'package:youtube/src/common/utils/file_name.dart';
import 'package:youtube/src/feature/download_export/models/download_export_failure.dart';

abstract interface class IDownloadExportRepository {
  /// Saves the video at [path] to the phone gallery.
  ///
  /// Throws [DownloadExportException].
  Future<void> saveToGallery(String path);

  /// Copies the file at [path] into the public Downloads folder, named after [title].
  ///
  /// Throws [DownloadExportException].
  Future<void> saveToDownloads(String path, {required String title});
}

final class DownloadExportRepositoryImpl implements IDownloadExportRepository {
  DownloadExportRepositoryImpl({required this._mediaStore});

  final IDeviceMediaStore _mediaStore;

  @override
  Future<void> saveToGallery(String path) async {
    await _ensureExists(path);
    await _guard(() => _mediaStore.saveVideoToGallery(File(path)));
  }

  @override
  Future<void> saveToDownloads(String path, {required String title}) async {
    await _ensureExists(path);
    final extension = p.extension(path);
    final base = safeFileName(title.isEmpty ? p.basenameWithoutExtension(path) : title);
    await _guard(() => _mediaStore.saveToDownloads(File(path), '$base$extension'));
  }

  /// Maps the media store's errors to [DownloadExportException]s.
  Future<void> _guard(Future<void> Function() save) async {
    try {
      await save();
    } on MediaPermissionDeniedException {
      throw const DownloadExportException(DownloadExportFailure.permissionDenied);
    } on Object catch (error) {
      throw DownloadExportException(DownloadExportFailure.failed, error);
    }
  }

  Future<void> _ensureExists(String path) async {
    if (path.isEmpty || !File(path).existsSync()) {
      throw const DownloadExportException(DownloadExportFailure.fileMissing);
    }
  }
}
