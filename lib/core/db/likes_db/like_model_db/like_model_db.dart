import 'package:floor/floor.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';

@Entity(tableName: "likes_table")
class LikeModelDb extends BaseVideoModelDb {
  LikeModelDb({
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
  }) : super(
          id: id,
          videoId: videoId,
          videoThumbnailUrl: videoThumbnailUrl,
          views: views,
          duration: duration,
          title: title,
          channelName: channelName,
          channelThumb: channelThumb,
          videoDate: videoDate,
          dateTime: dateTime,
        );

  factory LikeModelDb.fromVideo(Video? video) {
    return LikeModelDb(
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

  static LikeModelDb? fromEntity(BaseVideoModelDb? baseVideoModelDb) {
    if (baseVideoModelDb == null) return null;
    return LikeModelDb(
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

  LikeModelDb copyWith({
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
      LikeModelDb(
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
