import 'package:path_provider/path_provider.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/library_downloads/data/sources/get_downloaded_files_source/get_downloaded_files_source.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class GetDownloadedFilesSourceImpl implements GetDownloadedFilesSource {
  @override
  Future<List<BaseDownloadedFileModel>> loadDownloadFiles() async {
    final externalStorage = await getExternalStorageDirectory();
    var dataFromStorage = await externalStorage?.list().toList();
    var dataFromDb = await locator<DbFloor>().downloadedFiles.getDownloadedFiles();

    for (int i = 0; i < dataFromDb.length; i++) {
      if (!(dataFromStorage ?? []).any((el) => el.path == dataFromDb[i].downloadedPath)) {
        dataFromDb.removeAt(i);
        i--;
      }
    }

    dataFromDb = dataFromDb.reversed.toList();

    return dataFromDb;
  }
}
