import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source.dart';
import 'package:youtube/features/library_downloads/domain/repository/library_downloads_repository.dart';

class LibraryDownloadsRepositoryImpl implements LibraryDownloadsRepository {
  final GetDownloadedFilesSource _getDownloadedFilesSource;

  LibraryDownloadsRepositoryImpl(
    this._getDownloadedFilesSource,
  );

  @override
  Future<List<BaseDownloadedFileModel>> loadDownloadFiles() =>
      _getDownloadedFilesSource.loadDownloadFiles();
}
