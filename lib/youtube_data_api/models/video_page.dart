import 'package:youtube/youtube_data_api/helpers/description_helper.dart';

class VideoPage {
  ///Get video id from video page
  String? videoId;

  ///Get video title from video page
  String? title;

  ///Get video date from video page
  String? date;

  ///Get video description from video page
  String? description;

  ///Get video channel name from video page
  String? channelName;

  ///Get video views count as string from video page
  String? viewCount;

  ///Get video likes count as string from video page
  String? likeCount;

  ///Get video unlikes count as string from video page
  String? unlikeCount;

  ///Get video channel thumbnail from video page
  String? channelThumb;

  ///Get channel id from video page
  String? channelId;

  ///Get channel subscribes count as string from video page
  String? subscribeCount;

  //
  String? videoThumb;

  //
  String? videoDuration;

  VideoPage({
    this.videoId,
    this.title,
    this.channelName,
    this.viewCount,
    this.subscribeCount,
    this.likeCount,
    this.unlikeCount,
    this.date,
    this.description,
    this.channelThumb,
    this.channelId,
    this.videoThumb,
    this.videoDuration,
  });

  VideoPage clone({
    String? videoId,
    String? title,
    String? date,
    String? description,
    String? channelName,
    String? viewCount,
    String? likeCount,
    String? unlikeCount,
    String? channelThumb,
    String? channelId,
    String? subscribeCount,

    //
    String? videoThumb,
    String? videoDuration,
  }) =>
      VideoPage(
        videoId: videoId ?? this.videoId,
        title: title ?? this.title,
        channelName: channelName ?? this.channelName,
        viewCount: viewCount ?? this.viewCount,
        subscribeCount: subscribeCount ?? this.subscribeCount,
        likeCount: likeCount ?? this.likeCount,
        unlikeCount: unlikeCount ?? this.unlikeCount,
        date: date ?? this.date,
        description: description ?? this.description,
        channelThumb: channelThumb ?? this.channelThumb,
        channelId: channelId ?? this.channelId,
        videoThumb: videoThumb ?? this.videoThumb,
        videoDuration: videoDuration ?? this.videoDuration,
      );

  factory VideoPage.fromMap(Map<String, dynamic>? map, String videoId) {
    return VideoPage(
      videoId: videoId,
      title: map?['results']?['results']?['contents']?[0]?['videoPrimaryInfoRenderer']?['title']
          ?['runs']?[0]?['text'],
      channelName: map?['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']
          ?['owner']?['videoOwnerRenderer']?['title']?['runs']?[0]?['text'],
      viewCount: map?['results']?['results']?['contents']?[0]?['videoPrimaryInfoRenderer']
          ?['viewCount']?['videoViewCountRenderer']?['shortViewCount']?['simpleText'],
      subscribeCount: map?['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']
          ?['owner']?['videoOwnerRenderer']?['subscriberCountText']?['simpleText'],
      likeCount: map?['results']?['results']?['contents']?[0]?['videoPrimaryInfoRenderer']
                      ?['videoActions']?['menuRenderer']?['topLevelButtons']?[0]
                  ?['segmentedLikeDislikeButtonViewModel']?['likeButtonViewModel']
              ?['likeButtonViewModel']?['toggleButtonViewModel']?['toggleButtonViewModel']
          ?['defaultButtonViewModel']?['buttonViewModel']?['title'],
      unlikeCount: '',
      description: collectDescriptionString(map?['results']?['results']?['contents']?[1]
          ?['videoSecondaryInfoRenderer']?['description']?['runs']),
      date: map?['results']?['results']?['contents']?[0]?['videoPrimaryInfoRenderer']?['dateText']
          ?['simpleText'],
      channelThumb: map?['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']
          ?['owner']?['videoOwnerRenderer']?['thumbnail']?['thumbnails']?[1]?['url'],
      channelId: map?['results']?['results']?['contents']?[1]?['videoSecondaryInfoRenderer']
          ?['owner']?['videoOwnerRenderer']?['navigationEndpoint']?['browseEndpoint']?['browseId'],
      videoThumb: "https://i.ytimg.com/vi/$videoId/hqdefault.jpg",
        videoDuration: map?['results']?['results']?['contents']?[0]?['videoPrimaryInfoRenderer']
          ?['lengthText']?['simpleText'],
    );
  }

  factory VideoPage.fromJson(Map<String, dynamic> json) {
    return VideoPage(
      videoId: json['videoId'],
      title: json['title'],
      date: json['date'],
      description: json['description'],
      channelName: json['channelName'],
      viewCount: json['viewCount'],
      likeCount: json['likeCount'],
      unlikeCount: json['unlikeCount'],
      channelThumb: json['channelThumb'],
      channelId: json['channelId'],
      subscribeCount: json['subscribeCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "videoId": videoId,
      "title": title,
      "date": date,
      'description': description,
      "channelName": channelName,
      "viewCount": viewCount,
      "likeCount": likeCount,
      "unlikeCount": unlikeCount,
      "channelThumb": channelThumb,
      "channelId": channelId,
      "subscribeCount": subscribeCount,
    };
  }
}
