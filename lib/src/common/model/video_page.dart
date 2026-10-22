import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/model/video_item.dart';

/// One page of videos and the token that requests the next page.
@immutable
class VideoPage {
  const VideoPage({required this.videos, this.continuation});

  /// An empty last page.
  static const empty = VideoPage(videos: []);

  final List<VideoItem> videos;

  /// Token for the next page; null when this is the last page.
  final String? continuation;

  bool get hasMore => continuation != null;
}
