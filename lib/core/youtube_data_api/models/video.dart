import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/youtube_data_api/models/thumbnail.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'video_data.dart';
import 'video_page.dart';

class Video {
  ///Youtube video id
  String? videoId;

  ///Youtube video duration
  String? duration;

  ///Youtube video title
  String? title;

  ///Youtube video channel name
  String? channelName;

  ///Youtube video views
  String? views;

  ///Youtube video thumbnail
  List<Thumbnail>? thumbnails;

  // video data
  VideoData? videoData;

  // loading video data boolean
  bool loadingVideoData = true;

  // error if loading video data trows an error
  bool errorOfLoadingVideoData = false;

  // new one
  String? channelThumbnailUrl;

  String? publishedDateTime;

  Video({
    this.videoId,
    this.duration,
    this.title,
    this.channelName,
    this.views,
    this.thumbnails,
    this.videoData,
    this.channelThumbnailUrl,
    this.publishedDateTime,
  });

  Video clone() => Video(
    videoId: videoId,
    duration: duration,
    title: title,
    channelName: channelName,
    views: views,
    thumbnails: thumbnails,
    videoData: videoData?.clone(),
    channelThumbnailUrl: channelThumbnailUrl,
  );

  factory Video.fromMap(Map<String, dynamic>? map) {
    List<Thumbnail>? thumbnails;
    String? tempChannelThumbnail;
    String? tempPublishedDateTime;

    final channelThumbnailRenderer =
        map?['videoRenderer']?['channelThumbnailSupportedRenderers'];
    if (channelThumbnailRenderer != null) {
      tempChannelThumbnail =
          channelThumbnailRenderer['channelThumbnailWithLinkRenderer']['thumbnail']['thumbnails'][0]['url'];
    }

    final publishedTimeText =
        map?['videoRenderer']?['publishedTimeText']?['simpleText'];

    if (publishedTimeText != null) {
      tempPublishedDateTime = publishedTimeText;
    }

    if (map?.containsKey("videoRenderer") ?? false) {
      //Trending and search videos
      final lengthText = map?['videoRenderer']?['lengthText'];
      final simpleText =
          map?['videoRenderer']?['shortViewCountText']?['simpleText'];
      thumbnails = [];
      map?['videoRenderer']?['thumbnail']?['thumbnails'].forEach((thumbnail) {
        thumbnails!.add(
          Thumbnail(
            url: thumbnail['url'],
            width: thumbnail['width'],
            height: thumbnail['height'],
          ),
        );
      });

      return Video(
        videoId: map?['videoRenderer']?['videoId'],
        duration: (lengthText == null) ? "LIVE" : lengthText?['simpleText'],
        title: map?['videoRenderer']?['title']?['runs']?[0]?['text'],
        channelName:
            map?['videoRenderer']?['longBylineText']?['runs'][0]['text'],
        thumbnails: thumbnails,
        views: simpleText ?? "LIVE",
        channelThumbnailUrl: tempChannelThumbnail,
        publishedDateTime: tempPublishedDateTime ?? "LIVE",
      );
    } else if (map?.containsKey("compactVideoRenderer") ?? false) {
      //Related videos
      thumbnails = [];
      map?['compactVideoRenderer']['thumbnail']['thumbnails'].forEach((
        thumbnail,
      ) {
        thumbnails!.add(
          Thumbnail(
            url: thumbnail['url'],
            width: thumbnail['width'],
            height: thumbnail['height'],
          ),
        );
      });
      return Video(
        videoId: map?['compactVideoRenderer']?['videoId'],
        title: map?['compactVideoRenderer']?['title']?['simpleText'],
        duration: map?['compactVideoRenderer']?['lengthText']?['simpleText'],
        thumbnails: thumbnails,
        channelName:
            map?['compactVideoRenderer']?['shortBylineText']?['runs']?[0]?['text'],
        views: map?['compactVideoRenderer']?['viewCountText']?['simpleText'],
        channelThumbnailUrl: tempChannelThumbnail,
        publishedDateTime: tempPublishedDateTime,
      );
    } else if (map?.containsKey("gridVideoRenderer") ?? false) {
      final String? simpleText =
          map?['gridVideoRenderer']?['shortViewCountText']?['simpleText'];
      thumbnails = [];
      map?['gridVideoRenderer']?['thumbnail']?['thumbnails'].forEach((
        thumbnail,
      ) {
        thumbnails!.add(
          Thumbnail(
            url: thumbnail['url'],
            width: thumbnail['width'],
            height: thumbnail['height'],
          ),
        );
      });
      return Video(
        videoId: map?['gridVideoRenderer']?['videoId'],
        title: map?['gridVideoRenderer']?['title']?['runs']?[0]?['text'],
        duration:
            map?['gridVideoRenderer']?['thumbnailOverlays']?[0]['thumbnailOverlayTimeStatusRenderer']?['text']?['simpleText'],
        thumbnails: thumbnails,
        views: (simpleText != null) ? simpleText : "???",
        channelThumbnailUrl: tempChannelThumbnail,
        publishedDateTime: tempPublishedDateTime,
      );
    }
    return Video();
  }

  factory Video.fromIsolate(Map<String, dynamic> json) {
    return Video(
      videoId: json['videoId'],
      duration: json['duration'],
      title: json['title'],
      channelName: json['channelName'],
      views: json['views'],
      videoData:
          json['videoData'] == null
              ? null
              : VideoData.fromJson(json['videoData']),
    );
  }

  factory Video.fromBaseVideoModelDb(BaseVideoModelDb? baseVideoModelDb) {
    return Video(
      videoId: baseVideoModelDb?.videoId,
      thumbnails: [Thumbnail(url: baseVideoModelDb?.videoThumbnailUrl)],
      views: baseVideoModelDb?.views,
      duration: baseVideoModelDb?.duration,
      title: baseVideoModelDb?.title,
      channelName: baseVideoModelDb?.channelName,
      videoData: VideoData(
        videosList: [],
        video: VideoPage(
          channelThumb: baseVideoModelDb?.channelThumb,
          date: baseVideoModelDb?.videoDate,
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "videoId": videoId,
      "duration": duration,
      "title": title,
      "channelName": channelName,
      "views": views,
      'videoData': videoData?.toJson(),
    };
  }

  Future<void> getVideoData(YoutubeDataApi youtubeDataApi) async {
    try {
      if (videoId == null) return;
      videoData = await youtubeDataApi.fetchVideoData(videoId!);
      loadingVideoData = false;
    } catch (e) {
      // debugPrint"get video data error is $e");
      errorOfLoadingVideoData = true;
    }
  }

  Map<String, dynamic> toDb() {
    return {};
  }
}
