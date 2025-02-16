import 'package:floor/floor.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/core/youtube_data_api/models/video_data.dart';

@Entity(tableName: 'video_history')
class VideoModelDb extends BaseVideoModelDb {
  VideoModelDb({
    super.id,
    super.videoId,
    super.videoThumbnailUrl,
    super.views,
    super.duration,
    super.title,
    super.channelName,
    super.channelThumb,
    super.videoDate,
    super.dateTime,
  });

  factory VideoModelDb.fromVideo(Video? video) {
    return VideoModelDb(
      videoId: video?.videoId,
      videoThumbnailUrl: video?.thumbnails?.last.url,
      views: video?.views,
      duration: video?.duration,
      title: video?.title,
      channelName: video?.channelName,
      channelThumb: video?.channelThumbnailUrl,
      videoDate: video?.publishedDateTime,
    );
  }

  static VideoModelDb? fromEntity(BaseVideoModelDb? baseVideoModelDb) {
    if (baseVideoModelDb == null) return null;
    return VideoModelDb(
      id: baseVideoModelDb.id,
      videoId: baseVideoModelDb.videoId,
      videoThumbnailUrl: baseVideoModelDb.videoThumbnailUrl,
      views: baseVideoModelDb.views,
      duration: baseVideoModelDb.duration,
      title: baseVideoModelDb.title,
      channelName: baseVideoModelDb.channelName,
      channelThumb: baseVideoModelDb.channelThumb,
      videoDate: baseVideoModelDb.videoDate,
      dateTime: baseVideoModelDb.dateTime,
    );
  }

  static VideoModelDb? fromVideoData(VideoData? videoData) {
    if (videoData == null) return null;
    return VideoModelDb(
      videoId: videoData.video?.videoId,
      views: videoData.video?.viewCount,
      // duration: videoData.video?.,
      title: videoData.video?.title,
      channelName: videoData.video?.channelName,
      channelThumb: videoData.video?.channelThumb,
      videoDate: videoData.video?.date,
      // dateTime: videoData.video?.dateTime,
    );
  }

  VideoModelDb copyWith({
    int? id,
    String? videoId,
    String? videoThumbnailUrl,
    String? views,
    String? duration,
    String? title,
    String? channelName,
    String? channelThumb,
    String? videoDate,
    String? dateTime,
  }) =>
      VideoModelDb(
        id: id ?? this.id,
        videoId: videoId ?? this.videoId,
        videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
        views: views ?? this.views,
        duration: duration ?? this.duration,
        title: title ?? this.title,
        channelName: channelName ?? this.channelName,
        channelThumb: channelThumb ?? this.channelThumb,
        videoDate: videoDate ?? this.videoDate,
        dateTime: dateTime ?? this.dateTime,
      );
}
