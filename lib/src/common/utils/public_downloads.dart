import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Thrown when the user denies the storage permission (Android 9 and older).
final class StoragePermissionDeniedException implements Exception {
  const StoragePermissionDeniedException();

  @override
  String toString() => 'Storage permission denied';
}

/// Saves files where users find them outside the app: `Download/FTube` on Android, and the
/// app's `Documents/FTube` folder on iOS (shown in the Files app).
final class PublicDownloads {
  const PublicDownloads();

  static const _channel = MethodChannel('ftube/public_downloads');

  /// Copies [file] in as [fileName] and returns where it was saved.
  Future<String> save(File file, {required String fileName}) async {
    if (Platform.isAndroid) {
      final sdk = await _channel.invokeMethod<int>('sdkVersion');
      if (sdk != null && sdk <= 28 && !(await Permission.storage.request()).isGranted) {
        throw const StoragePermissionDeniedException();
      }
      final location = await _channel.invokeMethod<String>('save', {
        'path': file.path,
        'name': fileName,
        'mimeType': mimeTypeOf(fileName),
      });
      if (location == null) throw FileSystemException('Not saved', file.path);
      return location;
    }
    final directory = await Directory(
      p.join((await getApplicationDocumentsDirectory()).path, 'FTube'),
    ).create(recursive: true);
    var target = File(p.join(directory.path, fileName));
    for (var n = 2; target.existsSync(); n++) {
      target = File(
        p.join(
          directory.path,
          '${p.basenameWithoutExtension(fileName)} ($n)${p.extension(fileName)}',
        ),
      );
    }
    return (await file.copy(target.path)).path;
  }
}

/// MIME type for a downloaded media file name.
String mimeTypeOf(String fileName) => switch (p.extension(fileName).toLowerCase()) {
  '.m4a' || '.aac' => 'audio/mp4',
  '.mp3' => 'audio/mpeg',
  '.opus' || '.ogg' => 'audio/ogg',
  '.weba' => 'audio/webm',
  '.webm' => 'video/webm',
  '.mp4' => 'video/mp4',
  _ => 'application/octet-stream',
};
