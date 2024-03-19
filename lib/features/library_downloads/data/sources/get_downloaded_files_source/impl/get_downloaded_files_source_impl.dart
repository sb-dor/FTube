import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source/get_downloaded_files_source.dart';

class GetDownloadedFilesSourceImpl implements GetDownloadedFilesSource {
  @override
  Future<List<FileSystemEntity>> loadDownloadFiles() async {
    final externalStorage = await getExternalStorageDirectory();
    var data = await externalStorage?.list().toList();
    return data ?? <FileSystemEntity>[];
  }
}
