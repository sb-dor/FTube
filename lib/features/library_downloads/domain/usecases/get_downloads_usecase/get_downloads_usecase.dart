import 'dart:io';

import 'package:youtube/features/library_downloads/domain/repository/library_downloads_repository.dart';

class GetDownloadsUseCase {
  final LibraryDownloadsRepository _libraryDownloadsRepository;

  GetDownloadsUseCase(this._libraryDownloadsRepository);

  Future<List<FileSystemEntity>> loadDownloadFiles() =>
      _libraryDownloadsRepository.loadDownloadFiles();
}
