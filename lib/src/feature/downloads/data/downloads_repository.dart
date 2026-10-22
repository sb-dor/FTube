import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

/// Directories a downloaded file may have moved to; see [DownloadsRepositoryImpl].
typedef StorageDirectories = Future<List<Directory>> Function();

abstract interface class IDownloadsRepository {
  /// Downloaded files, newest first. Emits again whenever the downloads table changes.
  ///
  /// Files that are no longer on the device are included with [DownloadedFile.exists] false.
  Stream<List<DownloadedFile>> watchDownloads();
}

final class DownloadsRepositoryImpl implements IDownloadsRepository {
  DownloadsRepositoryImpl({
    required this._database,
    this._storageDirectories = defaultStorageDirectories,
  });

  final AppDatabase _database;
  final StorageDirectories _storageDirectories;
  Future<List<Directory>>? _directories;

  /// The app's documents and support directories, plus external storage on Android.
  static Future<List<Directory>> defaultStorageDirectories() async {
    Future<Directory?> safe(Future<Directory?> Function() get) async {
      try {
        return await get();
      } on Object {
        return null;
      }
    }

    return [
      ?await safe(getApplicationDocumentsDirectory),
      ?await safe(getApplicationSupportDirectory),
      if (Platform.isAndroid) ?await safe(getExternalStorageDirectory),
    ];
  }

  @override
  Stream<List<DownloadedFile>> watchDownloads() {
    final query = _database.select(_database.fileDownloads)
      ..orderBy([(table) => OrderingTerm.desc(table.id)]);
    return query.watch().asyncMap(_resolveAll);
  }

  Future<List<DownloadedFile>> _resolveAll(List<FileDownloadRow> rows) async {
    final directories = await (_directories ??= _loadDirectories());
    return [for (final row in rows) _resolve(row, directories)];
  }

  Future<List<Directory>> _loadDirectories() async {
    try {
      return await _storageDirectories();
    } on Object {
      _directories = null;
      return const [];
    }
  }

  DownloadedFile _resolve(FileDownloadRow row, List<Directory> directories) {
    final stored = row.downloadedPath ?? '';
    final found = _locate(stored, directories);
    final videoId = row.videoId;
    return DownloadedFile(
      id: row.id,
      title: row.name ?? '',
      path: found ?? stored,
      storedPath: row.downloadedPath,
      mediaType: DownloadMediaType.resolve(row.mediaType, stored),
      exists: found != null,
      thumbnailUrl:
          row.imagePath ??
          (videoId == null || videoId.isEmpty
              ? null
              : 'https://i.ytimg.com/vi/$videoId/hqdefault.jpg'),
      channelName: row.channelName,
      viewsText: row.views,
      videoId: videoId,
      duration: switch (row.durationSeconds) {
        final seconds? => Duration(seconds: seconds),
        null => null,
      },
      createdAt: row.createdAt,
    );
  }

  /// The stored path when the file is there; otherwise the same file name inside one of the
  /// storage [directories] or their `downloads` subfolder (the sandbox path changes between
  /// iOS installs and updates). Null when the file is gone.
  String? _locate(String stored, List<Directory> directories) {
    if (stored.isEmpty) return null;
    if (File(stored).existsSync()) return stored;
    final name = p.basename(stored);
    for (final directory in directories) {
      for (final candidate in [
        p.join(directory.path, name),
        p.join(directory.path, 'downloads', name),
      ]) {
        if (candidate != stored && File(candidate).existsSync()) return candidate;
      }
    }
    return null;
  }
}
