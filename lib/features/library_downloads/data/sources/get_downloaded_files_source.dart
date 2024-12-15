import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';

abstract class GetDownloadedFilesSource {
  Future<List<BaseDownloadedFileModel>> loadDownloadFiles();
}
