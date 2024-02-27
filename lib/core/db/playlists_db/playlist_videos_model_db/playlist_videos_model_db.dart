import 'package:floor/floor.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

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
      channelThumb: video?.videoData?.video?.channelThumb,
      videoDate: video?.videoData?.video?.date,
    );
  }
}
