import 'package:floor/floor.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/youtube_data_api/models/video_data.dart';

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
    bool savingToSpecificPath = false,
  }) : super(
          id: id,
          name: name,
          downloadedPath: downloadedPath,
          imagePath: imagePath,
          views: views,
          createdAt: createdAt,
          channelName: channelName,
          savingToSpecificPath: savingToSpecificPath,
        );

  factory FileDownloadModel.fromVideoData(VideoData? videoData) {
    DateTime now = DateTime.now();
    return FileDownloadModel(
      name: videoData?.video?.title,
      views: videoData?.video?.viewCount,
      createdAt: now.toString().substring(0, 16),
      channelName: videoData?.video?.channelName,
    );
  }
}
