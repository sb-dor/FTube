import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/model/video_page.dart';

/// Watch-page information about one video, plus the first page of related videos.
@immutable
class VideoDetails {
  const VideoDetails({
    required this.id,
    required this.title,
    required this.related,
    this.viewsText,
    this.publishedText,
    this.channelName,
    this.channelId,
    this.channelAvatarUrl,
    this.subscribersText,
    this.likesText,
    this.description,
  });

  final String id;
  final String title;

  /// Short view count, e.g. `1.2M views`.
  final String? viewsText;

  /// Publish date text, e.g. `Aug 2, 2020`.
  final String? publishedText;
  final String? channelName;
  final String? channelId;
  final String? channelAvatarUrl;

  /// Subscriber count text, e.g. `32.6K subscribers`.
  final String? subscribersText;

  /// Like count text, e.g. `7K`.
  final String? likesText;
  final String? description;
  final VideoPage related;

  String get thumbnailUrl => 'https://i.ytimg.com/vi/$id/hqdefault.jpg';
}
