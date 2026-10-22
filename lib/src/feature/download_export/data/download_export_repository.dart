import 'dart:io';

import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:youtube/src/common/utils/file_name.dart';
import 'package:youtube/src/common/utils/public_downloads.dart';

/// Why saving a file to the phone failed.
enum DownloadExportFailure { fileMissing, permissionDenied, failed }

final class DownloadExportException implements Exception {
  const DownloadExportException(this.failure, [this.cause]);

  final DownloadExportFailure failure;
  final Object? cause;

  @override
  String toString() => 'DownloadExportException($failure, $cause)';
}

/// Copies [path] into the public Downloads folder as [fileName].
typedef CopyIntoDownloads = Future<void> Function(String path, String fileName);

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
  /// The platform hooks are replaceable for tests; the defaults use `gal` and
  /// [PublicDownloads].
  DownloadExportRepositoryImpl({
    Future<bool> Function()? requestGalleryAccess,
    Future<void> Function(String path)? putVideo,
    CopyIntoDownloads? copyIntoDownloads,
  }) : _requestGalleryAccess = requestGalleryAccess ?? _defaultRequestGalleryAccess,
       _putVideo = putVideo ?? Gal.putVideo,
       _copyIntoDownloads = copyIntoDownloads ?? _defaultCopyIntoDownloads;

  final Future<bool> Function() _requestGalleryAccess;
  final Future<void> Function(String path) _putVideo;
  final CopyIntoDownloads _copyIntoDownloads;

  static Future<bool> _defaultRequestGalleryAccess() async =>
      await Gal.hasAccess() || await Gal.requestAccess();

  static Future<void> _defaultCopyIntoDownloads(String path, String fileName) =>
      const PublicDownloads().save(File(path), fileName: fileName);

  @override
  Future<void> saveToGallery(String path) async {
    await _ensureExists(path);
    final bool access;
    try {
      access = await _requestGalleryAccess();
    } on Object catch (error) {
      throw DownloadExportException(DownloadExportFailure.failed, error);
    }
    if (!access) throw const DownloadExportException(DownloadExportFailure.permissionDenied);
    try {
      await _putVideo(path);
    } on GalException catch (error) {
      throw DownloadExportException(
        error.type == GalExceptionType.accessDenied
            ? DownloadExportFailure.permissionDenied
            : DownloadExportFailure.failed,
        error,
      );
    } on Object catch (error) {
      throw DownloadExportException(DownloadExportFailure.failed, error);
    }
  }

  @override
  Future<void> saveToDownloads(String path, {required String title}) async {
    await _ensureExists(path);
    try {
      final extension = p.extension(path);
      final base = safeFileName(title.isEmpty ? p.basenameWithoutExtension(path) : title);
      await _copyIntoDownloads(path, '$base$extension');
    } on StoragePermissionDeniedException {
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
