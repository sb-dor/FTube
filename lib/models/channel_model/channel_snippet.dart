import 'package:youtube/models/thumbnails.dart';

class ChannelSnippet {
  String? title;
  String? description;
  String? customUrl;
  String? publishedAt;
  Thumbnail? thumbDefault;
  Thumbnail? thumbMedium;
  Thumbnail? thumbHigh;
  String? country;

  ChannelSnippet({
    this.title,
    this.description,
    this.customUrl,
    this.publishedAt,
    this.thumbDefault,
    this.thumbMedium,
    this.thumbHigh,
    this.country,
  });

  factory ChannelSnippet.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? thumbDefault;
    Map<String, dynamic>? thumbMedium;
    Map<String, dynamic>? thumbHigh;
    if (json['thumbnails'] != null) {
      thumbDefault = json['thumbnails']['default'];
      thumbMedium = json['thumbnails']['medium'];
      thumbHigh = json['thumbnails']['high'];
    }
    return ChannelSnippet(
      title: json['title'],
      description: json['description'],
      customUrl: json['customUrl'],
      thumbDefault: thumbDefault == null ? null : Thumbnail.fromJson(thumbDefault),
      thumbMedium: thumbMedium == null ? null : Thumbnail.fromJson(thumbMedium),
      thumbHigh: thumbHigh == null ? null : Thumbnail.fromJson(thumbHigh),
      country: json['country'],
    );
  }
}
