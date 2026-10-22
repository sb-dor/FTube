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
  Future<void> saveVideoToGallery(File file);

  /// Copies an audio file into the public Downloads folder (`Download/FTube`) as [fileName].
  Future<void> saveToDownloads(File file, String fileName);

  /// Directory for files kept inside the app (Library → In-App downloads).
  Future<Directory> appDownloadsDirectory();
}

final class DeviceMediaStoreImpl implements IDeviceMediaStore {
  const DeviceMediaStoreImpl();

  @override
  Future<void> saveVideoToGallery(File file) async {
    if (!await Gal.hasAccess() && !await Gal.requestAccess()) {
      throw const MediaPermissionDeniedException();
    }
    await Gal.putVideo(file.path);
  }

  @override
  Future<void> saveToDownloads(File file, String fileName) async {
    try {
      await const PublicDownloads().save(file, fileName: fileName);
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
