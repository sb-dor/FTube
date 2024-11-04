import 'package:floor/floor.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';

@Entity(tableName: 'playlist_videos', foreignKeys: [
  ForeignKey(
    childColumns: ['play_list_id'],
    parentColumns: ['id'],
    entity: PlaylistModelDb,
  )
])
class PlaylistVideosModelDb extends BaseVideoModelDb {
  @ColumnInfo(name: "play_list_id")
  final int? playlistId;

  PlaylistVideosModelDb({
    int? id,
    this.playlistId,
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

  factory PlaylistVideosModelDb.fromVideo(Video? video) {
    return PlaylistVideosModelDb(
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

  static PlaylistVideosModelDb? fromEntity(BaseVideoModelDb? baseVideoModelDb) {
    if (baseVideoModelDb == null) return null;
    return PlaylistVideosModelDb(
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

  PlaylistVideosModelDb copyWith({
    int? id,
    int? playlistId,
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
      PlaylistVideosModelDb(
        id: id ?? this.id,
        playlistId: playlistId ?? this.playlistId,
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
