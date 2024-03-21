import 'package:floor/floor.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';

@Entity(tableName: "file_downloads")
class FileDownloadModel extends BaseDownloadedFileModel {
  FileDownloadModel({
    int? id,
    String? name,
    String? downloadedPath,
    String? imagePath,
    String? views,
    String? createdAt,
    String? channelName,
  }) : super(
          id: id,
          name: name,
          downloadedPath: downloadedPath,
          imagePath: imagePath,
          views: views,
          createdAt: createdAt,
          channelName: channelName,
        );
}
