import 'package:youtube/core/youtube_data_api/models/video.dart';

class TrendsVideosModel extends Video {
  TrendsVideosModel({
    super.videoId,
    super.duration,
    super.title,
    super.channelName,
    super.views,
    super.thumbnails,
    // VideoData? videoData,
    super.channelThumbnailUrl,
    super.publishedDateTime,
  });

  factory TrendsVideosModel.fromEntity(Video video) {
    return TrendsVideosModel(
      videoId: video.videoId,
      duration: video.duration,
      title: video.title,
      channelName: video.channelName,
      views: video.views,
      thumbnails: video.thumbnails,
      channelThumbnailUrl: video.channelThumbnailUrl,
      publishedDateTime: video.publishedDateTime,
    );
  }
}
