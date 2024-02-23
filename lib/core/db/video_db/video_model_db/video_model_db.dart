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

  String? channelName;

  String? channelThumb;

  String? videoDate;

  VideoModelDb({
    this.id,
    this.videoId,
    this.videoThumbnailUrl,
    this.views,
    this.duration,
    this.title,
    this.channelName,
    this.channelThumb,
    this.videoDate,
  });

  factory VideoModelDb.fromVideo(Video? video) {
    return VideoModelDb(
      videoId: video?.videoId,
      videoThumbnailUrl: video?.thumbnails?.last.url,
      views: video?.views,
      duration: video?.duration,
      title: video?.title,
      channelName: video?.channelName,
      channelThumb: video?.videoData?.video?.channelThumb,
      videoDate: video?.videoData?.video?.date,
    );
  }
}
