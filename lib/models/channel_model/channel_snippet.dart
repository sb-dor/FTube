import 'package:youtube/api/api_get_data/rest_api_get_channel_data.dart';
import 'package:youtube/models/channel_model/channel_statistics.dart';
import 'package:youtube/models/thumbnails.dart';
import 'package:youtube/utils/enums.dart';

class ChannelSnippet {
  String? channelId;
  String? title;
  String? description;
  String? customUrl;
  String? publishedAt;
  Thumbnail? thumbDefault;
  Thumbnail? thumbMedium;
  Thumbnail? thumbHigh;
  String? country;

  //
  bool loadingStatistics = true;
  bool errorStatistics = false;
  ChannelStatistics? channelStatistics;

  //
  ChannelSnippet({
    this.channelId,
    this.title,
    this.description,
    this.customUrl,
    this.publishedAt,
    this.thumbDefault,
    this.thumbMedium,
    this.thumbHigh,
    this.country,
    this.channelStatistics,
  });

  factory ChannelSnippet.fromJson(Map<String, dynamic> json, {String? channelId}) {
    Map<String, dynamic>? thumbDefault;
    Map<String, dynamic>? thumbMedium;
    Map<String, dynamic>? thumbHigh;
    if (json['thumbnails'] != null) {
      thumbDefault = json['thumbnails']['default'];
      thumbMedium = json['thumbnails']['medium'];
      thumbHigh = json['thumbnails']['high'];
    }
    return ChannelSnippet(
      channelId: channelId,
      title: json['title'],
      description: json['description'],
      customUrl: json['customUrl'],
      thumbDefault: thumbDefault == null ? null : Thumbnail.fromJson(thumbDefault),
      thumbMedium: thumbMedium == null ? null : Thumbnail.fromJson(thumbMedium),
      thumbHigh: thumbHigh == null ? null : Thumbnail.fromJson(thumbHigh),
      country: json['country'],
    );
  }

  Future<void> loadSnippetData() async {
    await _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    loadingStatistics = true;
    try {
      var data = await RestApiGetChannelData.channel(
        typeContent: TypeContent.statistics,
        channelId: channelId,
      );
      if (data.containsKey('server_error')) {
        errorStatistics = true;
      } else if (data.containsKey('success')) {
        channelStatistics = ChannelStatistics.fromJson(data['item']);
      }
    } catch (e) {
      errorStatistics = false;
    }
    loadingStatistics = false;
  }
}
