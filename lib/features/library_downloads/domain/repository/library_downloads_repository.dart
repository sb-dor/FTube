import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';

abstract class LibraryDownloadsRepository {
  Future<List<BaseDownloadedFileModel>> loadDownloadFiles();
}
