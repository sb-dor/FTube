import 'dart:io';

import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

abstract interface class IDownloadDeletionRepository {
  /// Deletes the downloaded [file] from the device and its database row.
  /// A file that is already gone only loses its row.
  Future<void> delete(DownloadedFile file);
}

final class DownloadDeletionRepositoryImpl implements IDownloadDeletionRepository {
  DownloadDeletionRepositoryImpl({required this._database});

  final AppDatabase _database;

  @override
  Future<void> delete(DownloadedFile file) async {
    for (final path in {file.path, ?file.storedPath}) {
      if (path.isEmpty) continue;
      final entity = File(path);
      if (entity.existsSync()) entity.deleteSync();
    }
    await (_database.delete(
      _database.fileDownloads,
    )..where((table) => table.id.equals(file.id))).go();
  }
}
