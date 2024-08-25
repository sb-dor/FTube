import 'package:floor/floor.dart';
import 'package:youtube/core/db/downloaded_file_db/file_downloaded_model/file_downloaded_model.dart';

@dao
abstract class FileDownloadedDao {
  @Query("select * from file_downloads")
  Future<List<FileDownloadModel>> getDownloadedFiles();

  @Query("select count(*) from file_downloads")
  Future<int?> getCountOfDownloadedFiles();

  @insert
  Future<void> insertDownloadedFile(FileDownloadModel fileDownloadModel);

  @Query("delete from file_downloads where downloaded_path = :path")
  Future<void> deleteDownloadedFile(String path);
}
