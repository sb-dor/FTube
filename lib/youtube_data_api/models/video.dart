import 'package:flutter/material.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/thumbnail.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

import 'video_data.dart';

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

  Video({
    this.videoId,
    this.duration,
    this.title,
    this.channelName,
    this.views,
    this.thumbnails,
    this.videoData,
  });

  Video clone() => Video(
        videoId: videoId,
        duration: duration,
        title: title,
        channelName: channelName,
        views: views,
        thumbnails: thumbnails,
        videoData: videoData?.clone(),
      );

  factory Video.fromMap(Map<String, dynamic>? map) {
    List<Thumbnail>? thumbnails;
    if (map?.containsKey("videoRenderer") ?? false) {
      //Trending and search videos
      var lengthText = map?['videoRenderer']?['lengthText'];
      var simpleText = map?['videoRenderer']?['shortViewCountText']?['simpleText'];
      thumbnails = [];
      map?['videoRenderer']?['thumbnail']?['thumbnails'].forEach((thumbnail) {
        thumbnails!.add(Thumbnail(
            url: thumbnail['url'], width: thumbnail['width'], height: thumbnail['height']));
      });
      return Video(
          videoId: map?['videoRenderer']?['videoId'],
          duration: (lengthText == null) ? "Live" : lengthText?['simpleText'],
          title: map?['videoRenderer']?['title']?['runs']?[0]?['text'],
          channelName: map?['videoRenderer']?['longBylineText']?['runs'][0]['text'],
          thumbnails: thumbnails,
          views: simpleText);
    } else if (map?.containsKey("compactVideoRenderer") ?? false) {
      //Related videos
      thumbnails = [];
      map?['compactVideoRenderer']['thumbnail']['thumbnails'].forEach((thumbnail) {
        thumbnails!.add(Thumbnail(
            url: thumbnail['url'], width: thumbnail['width'], height: thumbnail['height']));
      });
      return Video(
          videoId: map?['compactVideoRenderer']?['videoId'],
          title: map?['compactVideoRenderer']?['title']?['simpleText'],
          duration: map?['compactVideoRenderer']?['lengthText']?['simpleText'],
          thumbnails: thumbnails,
          channelName: map?['compactVideoRenderer']?['shortBylineText']?['runs']?[0]?['text'],
          views: map?['compactVideoRenderer']?['viewCountText']?['simpleText']);
    } else if (map?.containsKey("gridVideoRenderer") ?? false) {
      String? simpleText = map?['gridVideoRenderer']?['shortViewCountText']?['simpleText'];
      thumbnails = [];
      map?['gridVideoRenderer']?['thumbnail']?['thumbnails'].forEach((thumbnail) {
        thumbnails!.add(Thumbnail(
            url: thumbnail['url'], width: thumbnail['width'], height: thumbnail['height']));
      });
      return Video(
          videoId: map?['gridVideoRenderer']?['videoId'],
          title: map?['gridVideoRenderer']?['title']?['runs']?[0]?['text'],
          duration: map?['gridVideoRenderer']?['thumbnailOverlays']?[0]
              ['thumbnailOverlayTimeStatusRenderer']?['text']?['simpleText'],
          thumbnails: thumbnails,
          views: (simpleText != null) ? simpleText : "???");
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
      videoData: json['videoData'] == null ? null : VideoData.fromJson(json['videoData']),
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

  Future<void> getVideoData() async {
    try {
      if (videoId == null) return;
      videoData = await locator.get<YoutubeDataApi>().fetchVideoData(videoId!);
      loadingVideoData = false;
    } catch (e) {
      debugPrint("get video data error is $e");
      errorOfLoadingVideoData = true;
    }
  }
}
