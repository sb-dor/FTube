import 'dart:io';

import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube/src/common/utils/public_downloads.dart';

/// Thrown when the user denies access to the gallery or storage.
final class MediaPermissionDeniedException implements Exception {
  const MediaPermissionDeniedException();

  @override
  String toString() => 'Media permission denied';
}

/// Destinations outside the app: the Gallery, the public Downloads folder, and the app's own
/// downloads directory.
abstract interface class IDeviceMediaStore {
  /// Adds a video file to the Gallery.
  ///
  /// Throws [MediaPermissionDeniedException] when gallery access is denied.
  Future<void> saveVideoToGallery(File file);

  /// Copies a file into the public Downloads folder (`Download/FTube`) as [fileName].
  ///
  /// Throws [MediaPermissionDeniedException] when the storage permission is denied.
  Future<void> saveToDownloads(File file, String fileName);

  /// Directory for files kept inside the app (Library → In-App downloads).
  Future<Directory> appDownloadsDirectory();
}

final class DeviceMediaStoreImpl implements IDeviceMediaStore {
  /// The platform hooks are replaceable for tests; the defaults use `gal` and
  /// [PublicDownloads].
  DeviceMediaStoreImpl({
    Future<bool> Function()? requestGalleryAccess,
    Future<void> Function(String path)? putVideo,
    Future<void> Function(File file, String fileName)? copyIntoDownloads,
  }) : _requestGalleryAccess = requestGalleryAccess ?? _defaultRequestGalleryAccess,
       _putVideo = putVideo ?? Gal.putVideo,
       _copyIntoDownloads = copyIntoDownloads ?? _defaultCopyIntoDownloads;

  final Future<bool> Function() _requestGalleryAccess;
  final Future<void> Function(String path) _putVideo;
  final Future<void> Function(File file, String fileName) _copyIntoDownloads;

  static Future<bool> _defaultRequestGalleryAccess() async =>
      await Gal.hasAccess() || await Gal.requestAccess();

  static Future<void> _defaultCopyIntoDownloads(File file, String fileName) =>
      const PublicDownloads().save(file, fileName: fileName);

  @override
  Future<void> saveVideoToGallery(File file) async {
    if (!await _requestGalleryAccess()) throw const MediaPermissionDeniedException();
    try {
      await _putVideo(file.path);
    } on GalException catch (error) {
      if (error.type == GalExceptionType.accessDenied) {
        throw const MediaPermissionDeniedException();
      }
      rethrow;
    }
  }

  @override
  Future<void> saveToDownloads(File file, String fileName) async {
    try {
      await _copyIntoDownloads(file, fileName);
    } on StoragePermissionDeniedException {
      throw const MediaPermissionDeniedException();
    }
  }

  @override
  Future<Directory> appDownloadsDirectory() async {
    final base = Platform.isAndroid
        ? await getExternalStorageDirectory() ?? await getApplicationDocumentsDirectory()
        : await getApplicationDocumentsDirectory();
    return Directory('${base.path}/downloads').create(recursive: true);
  }
}
