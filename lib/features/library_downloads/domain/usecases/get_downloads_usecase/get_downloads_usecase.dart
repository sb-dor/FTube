import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/features/library_downloads/domain/repository/library_downloads_repository.dart';

class GetDownloadsUseCase {
  final LibraryDownloadsRepository _libraryDownloadsRepository;

  GetDownloadsUseCase(this._libraryDownloadsRepository);

  Future<List<BaseDownloadedFileModel>> loadDownloadFiles() =>
      _libraryDownloadsRepository.loadDownloadFiles();
}
