import 'package:flutter/foundation.dart';

/// A video as shown in lists: search results, related videos, history, playlists.
///
/// Texts such as [viewsText] and [publishedText] come pre-formatted from YouTube in the
/// requested language, or from the database for saved videos.
@immutable
class VideoItem {
  const VideoItem({
    required this.id,
    required this.title,
    this.channelName,
    this.channelId,
    this.channelAvatarUrl,
    this.thumbnailUrl,
    this.viewsText,
    this.durationText,
    this.publishedText,
    this.isLive = false,
  });

  /// YouTube video id.
  final String id;
  final String title;
  final String? channelName;
  final String? channelId;
  final String? channelAvatarUrl;
  final String? thumbnailUrl;

  /// Short view count, e.g. `1.2M views`.
  final String? viewsText;

  /// Duration, e.g. `12:34`; null for live streams.
  final String? durationText;

  /// Relative publish time, e.g. `3 days ago`.
  final String? publishedText;
  final bool isLive;

  /// Thumbnail to show: the scraped one, or YouTube's standard high-quality thumbnail.
  String get thumbnail => thumbnailUrl ?? 'https://i.ytimg.com/vi/$id/hqdefault.jpg';

  VideoItem copyWith({
    String? id,
    String? title,
    ValueGetter<String?>? channelName,
    ValueGetter<String?>? channelId,
    ValueGetter<String?>? channelAvatarUrl,
    ValueGetter<String?>? thumbnailUrl,
    ValueGetter<String?>? viewsText,
    ValueGetter<String?>? durationText,
    ValueGetter<String?>? publishedText,
    bool? isLive,
  }) => VideoItem(
    id: id ?? this.id,
    title: title ?? this.title,
    channelName: channelName != null ? channelName() : this.channelName,
    channelId: channelId != null ? channelId() : this.channelId,
    channelAvatarUrl: channelAvatarUrl != null ? channelAvatarUrl() : this.channelAvatarUrl,
    thumbnailUrl: thumbnailUrl != null ? thumbnailUrl() : this.thumbnailUrl,
    viewsText: viewsText != null ? viewsText() : this.viewsText,
    durationText: durationText != null ? durationText() : this.durationText,
    publishedText: publishedText != null ? publishedText() : this.publishedText,
    isLive: isLive ?? this.isLive,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoItem &&
          other.id == id &&
          other.title == title &&
          other.channelName == channelName &&
          other.channelId == channelId &&
          other.channelAvatarUrl == channelAvatarUrl &&
          other.thumbnailUrl == thumbnailUrl &&
          other.viewsText == viewsText &&
          other.durationText == durationText &&
          other.publishedText == publishedText &&
          other.isLive == isLive;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    channelName,
    channelId,
    channelAvatarUrl,
    thumbnailUrl,
    viewsText,
    durationText,
    publishedText,
    isLive,
  );

  @override
  String toString() => 'VideoItem($id, $title)';
}
