import 'dart:io';

abstract class LibraryDownloadsRepository {
  Future<List<FileSystemEntity>> loadDownloadFiles();
}
