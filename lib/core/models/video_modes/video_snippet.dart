import 'package:youtube/core/api/api_get_data/rest_api_get_channel_data.dart';
import 'package:youtube/core/api/api_get_data/rest_api_get_video_data.dart';
import 'package:youtube/core/models/channel_model/channel.dart';
import 'package:youtube/core/models/thumbnails.dart';
import 'package:youtube/core/models/video_modes/video.dart';
import 'package:youtube/core/models/video_modes/video_statistic.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/extensions.dart';
import 'video_content_details.dart';

class VideoSnippet extends Video {
  String? videoId;
  String? title;
  String? description;
  String? channelID;
  Channel? channel;
  VideoStatistic? statistic;
  VideoContentDetails? videoContentDetails;
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
  bool loadingContentDetails = true;
  bool errorContentDetails = false;

  //

  VideoSnippet({
    this.videoId,
    this.title,
    this.description,
    this.channelID,
    this.channel,
    this.statistic,
    this.videoContentDetails,
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
      thumbnailDefault:
          thumbDefault == null ? null : Thumbnail.fromJson(thumbDefault),
      thumbnailMedium:
          thumbMedium == null ? null : Thumbnail.fromJson(thumbMedium),
      thumbnailHigh: thumbHigh == null ? null : Thumbnail.fromJson(thumbHigh),
      channelTitle: json['channelTitle'],
      liveBroadcastContent: EnumExtensions.liveBroadcastContentJson(
        json['liveBroadcastContent'],
      ),
      publishTime: json['publishTime'],
    );
  }

  Future<void> loadSnippetData(RestApiGetVideoData data) async {
    await _loadChannel();
    await _loadStatistics(data);
    await _loadContentDetails(data);
  }

  Future<void> _loadChannel() async {
    loadingChannel = true;
    final data = await RestApiGetChannelData.channel(
      typeContent: TypeContent.snippet,
      channelId: channelID ?? '',
    );
    if (data.containsKey('server_error')) {
      errorChannel = true;
    } else if (data.containsKey('success')) {
      channel = Channel.fromJson(data['item']);
      await channel?.channelSnippet?.loadSnippetData();
    }
    loadingChannel = false;
  }

  Future<void> _loadStatistics(RestApiGetVideoData restApiGetVideoData) async {
    loadingStatistics = true;
    final data = await restApiGetVideoData.getVideoInfo(
      videoContent: TypeContent.statistics,
      videoId: videoId,
    );
    if (data.containsKey('server_error')) {
      errorStatistics = true;
    } else if (data.containsKey('success') && data['success'] == true) {
      statistic = VideoStatistic.fromJson(data['item']);
    }
    loadingStatistics = false;
  }

  Future<void> _loadContentDetails(
    RestApiGetVideoData restApiGetVideoData,
  ) async {
    loadingContentDetails = true;
    final data = await restApiGetVideoData.getVideoInfo(
      videoContent: TypeContent.contentDetails,
      videoId: videoId,
    );
    if (data.containsKey("server_error")) {
      errorContentDetails = true;
    } else if (data.containsKey('success') && data['success'] == true) {
      videoContentDetails = VideoContentDetails.fromJson(data['item']);
    }
    loadingContentDetails = false;
  }
}
