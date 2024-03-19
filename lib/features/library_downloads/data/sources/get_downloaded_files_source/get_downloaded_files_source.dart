import 'dart:io';

abstract class GetDownloadedFilesSource {
  Future<List<FileSystemEntity>> loadDownloadFiles();
}
