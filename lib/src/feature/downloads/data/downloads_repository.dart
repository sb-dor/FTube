import 'dart:io';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file_converter.dart';

/// Directories a downloaded file may have moved to; see [DownloadsRepositoryImpl].
typedef StorageDirectories = Future<List<Directory>> Function();

/// The newest [downloads] and whether older ones exist.
typedef DownloadsPage = ({List<DownloadedFile> downloads, bool hasMore});

abstract interface class IDownloadsRepository {
  /// The newest [limit] downloaded files, newest first. Emits again whenever the downloads
  /// table changes.
  ///
  /// Files that are no longer on the device are included with [DownloadedFile.exists] false.
  Stream<DownloadsPage> watchDownloads({required int limit});
}

final class DownloadsRepositoryImpl implements IDownloadsRepository {
  DownloadsRepositoryImpl({
    required this._database,
    this._storageDirectories = defaultStorageDirectories,
    this._converter = const DownloadedFileConverter(),
  });

  final AppDatabase _database;
  final StorageDirectories _storageDirectories;
  final DownloadedFileConverter _converter;
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
  Stream<DownloadsPage> watchDownloads({required int limit}) {
    // One extra row tells whether another page exists.
    final query = _database.select(_database.fileDownloads)
      ..orderBy([(table) => OrderingTerm.desc(table.id)])
      ..limit(limit + 1);
    return query.watch().asyncMap((rows) async {
      final page = rows.take(limit).toList();
      return (downloads: await _resolveAll(page), hasMore: rows.length > limit);
    });
  }

  Future<List<DownloadedFile>> _resolveAll(List<FileDownloadRow> rows) async {
    final directories = await (_directories ??= _loadDirectories());
    final stored = [for (final row in rows) row.downloadedPath ?? ''];
    final roots = [for (final directory in directories) directory.path];
    final located = rows.isEmpty ? const <String?>[] : await _locateInBackground(stored, roots);
    return [
      for (var i = 0; i < rows.length; i++) _converter.convert(rows[i], locatedPath: located[i]),
    ];
  }

  Future<List<Directory>> _loadDirectories() async {
    try {
      return await _storageDirectories();
    } on Object {
      _directories = null;
      return const [];
    }
  }

  /// One file-system check per row and directory: done on a background isolate so a long page
  /// does not stall the UI. Static, so the isolate closure captures only the paths.
  static Future<List<String?>> _locateInBackground(List<String> stored, List<String> roots) =>
      Isolate.run(() => _locateAll(stored, roots));

  /// For each stored path: the path when the file is there; otherwise the same file name inside
  /// one of the storage [directories] or their `downloads` subfolder (the sandbox path changes
  /// between iOS installs and updates). Null when the file is gone.
  static List<String?> _locateAll(List<String> stored, List<String> directories) => [
    for (final path in stored) _locate(path, directories),
  ];

  static String? _locate(String stored, List<String> directories) {
    if (stored.isEmpty) return null;
    if (File(stored).existsSync()) return stored;
    final name = p.basename(stored);
    for (final directory in directories) {
      for (final candidate in [p.join(directory, name), p.join(directory, 'downloads', name)]) {
        if (candidate != stored && File(candidate).existsSync()) return candidate;
      }
    }
    return null;
  }
}
