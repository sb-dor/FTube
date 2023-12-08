import 'package:youtube/api/api_get_data/rest_api_get_data.dart';
import 'package:youtube/models/channel_model/channel.dart';
import 'package:youtube/models/thumbnails.dart';
import 'package:youtube/models/video_modes/video.dart';
import 'package:youtube/models/video_modes/video_statistic.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/utils/extensions.dart';

class VideoSnippet extends Video {
  String? videoId;
  String? title;
  String? description;
  String? channelID;
  Channel? channel;
  VideoStatistic? statistic;
  String? publishedAt;
  String? channelTitle;
  Thumbnail? thumbnailDefault;
  Thumbnail? thumbnailMedium;
  Thumbnail? thumbnailHigh;
  LiveBroadcastContent? liveBroadcastContent;
  String? publishTime;

  //
  bool loadingChannel = true;
  bool errorChannel = false;
  bool loadingStatistics = true;
  bool errorStatistics = false;

  //

  VideoSnippet({
    this.videoId,
    this.title,
    this.description,
    this.channelID,
    this.channel,
    this.statistic,
    this.publishedAt,
    this.channelTitle,
    this.thumbnailDefault,
    this.thumbnailMedium,
    this.thumbnailHigh,
    this.liveBroadcastContent,
    this.publishTime,
  });

  factory VideoSnippet.fromJson(Map<String, dynamic> json, {String? videoId}) {
    Map<String, dynamic>? thumbDefault;
    Map<String, dynamic>? thumbMedium;
    Map<String, dynamic>? thumbHigh;
    if (json['thumbnails'] != null) {
      thumbDefault = json['thumbnails']['default'];
      thumbMedium = json['thumbnails']['medium'];
      thumbHigh = json['thumbnails']['high'];
    }
    return VideoSnippet(
      videoId: videoId,
      title: json['title'],
      description: json['description'],
      channelID: json['channelId'],
      publishedAt: json['publishedAt'],
      thumbnailDefault: thumbDefault == null ? null : Thumbnail.fromJson(thumbDefault),
      thumbnailMedium: thumbMedium == null ? null : Thumbnail.fromJson(thumbMedium),
      thumbnailHigh: thumbHigh == null ? null : Thumbnail.fromJson(thumbHigh),
      channelTitle: json['channelTitle'],
      liveBroadcastContent: EnumExtensions.liveBroadcastContentJson(json['liveBroadcastContent']),
      publishTime: json['publishTime'],
    );
  }

  Future<void> loadChannel() async {
    loadingChannel = true;
    var data = await RestApiGetData.channel(channelId: channelID ?? '');
    if (data.containsKey('server_error')) {
      errorChannel = true;
    } else if (data.containsKey('success')) {
      channel = data['channel'];
    }
    loadingChannel = false;
  }

  Future<void> loadStatistics() async {
    loadingStatistics = true;
    var data = await RestApiGetData.getVideoStatistics(videoId: videoId);
    if (data.containsKey('server_error')) {
      errorStatistics = true;
    } else if (data.containsKey('success') && data['success'] == true) {
      statistic = data['statistics'];
    }
    loadingStatistics = false;
  }
}
