import 'package:youtube/models/video_modes/thumbnails.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/extensions.dart';

class VideoSnippet {
  String? title;
  String? description;
  String? channelId;
  String? publishedAt;
  String? channelTitle;
  Thumbnail? thumbnailDefault;
  Thumbnail? thumbnailMedium;
  Thumbnail? thumbnailHigh;
  LiveBroadcastContent? liveBroadcastContent;
  String? publishTime;

  VideoSnippet({
    this.title,
    this.description,
    this.channelId,
    this.publishedAt,
    this.channelTitle,
    this.thumbnailDefault,
    this.thumbnailMedium,
    this.thumbnailHigh,
    this.liveBroadcastContent,
    this.publishTime,
  });

  factory VideoSnippet.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? thumbDefault;
    Map<String, dynamic>? thumbMedium;
    Map<String, dynamic>? thumbHigh;
    if (json['thumbnails'] != null) {
      thumbDefault = json['thumbnails']['default'];
      thumbMedium = json['thumbnails']['medium'];
      thumbHigh = json['thumbnails']['high'];
    }
    return VideoSnippet(
      title: json['title'],
      description: json['description'],
      channelId: json['channelId'],
      publishedAt: json['publishedAt'],
      thumbnailDefault: thumbDefault == null ? null : Thumbnail.fromJson(thumbDefault),
      thumbnailMedium: thumbMedium == null ? null : Thumbnail.fromJson(thumbMedium),
      thumbnailHigh: thumbHigh == null ? null : Thumbnail.fromJson(thumbHigh),
      channelTitle: json['channelTitle'],
      liveBroadcastContent: EnumExtensions.liveBroadcastContentJson(json['liveBroadcastContent']),
      publishTime: json['publishTime'],
    );
  }
}
