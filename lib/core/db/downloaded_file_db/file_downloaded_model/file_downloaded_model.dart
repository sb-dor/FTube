import 'package:floor/floor.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/core/youtube_data_api/models/video_data.dart';

@Entity(tableName: "file_downloads")
class FileDownloadModel extends BaseDownloadedFileModel {
  FileDownloadModel({
    super.id,
    super.name,
    super.downloadedPath,
    super.imagePath,
    super.views,
    super.createdAt,
    super.channelName,
    super.savingToSpecificPath = false,
  });

  factory FileDownloadModel.fromVideoData(VideoData? videoData) {
    final DateTime now = DateTime.now();
    return FileDownloadModel(
      name: videoData?.video?.title,
      views: videoData?.video?.viewCount,
      createdAt: now.toString().substring(0, 16),
      channelName: videoData?.video?.channelName,
    );
  }
}
