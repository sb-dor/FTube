import 'package:floor/floor.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

@Entity(tableName: 'video_history')
class VideoModelDb {
  @PrimaryKey(autoGenerate: true)
  int? id;

  String? videoId;

  String? videoThumbnailUrl;

  String? views;

  String? duration;

  String? title;

  VideoModelDb({
    this.videoId,
    this.videoThumbnailUrl,
    this.views,
    this.duration,
    this.title,
  });
}
