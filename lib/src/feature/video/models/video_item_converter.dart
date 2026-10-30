import 'dart:convert';

import 'package:youtube/src/common/model/video_details.dart';
import 'package:youtube/src/common/model/video_item.dart';

/// Converts loaded [VideoDetails] into the [VideoItem] saved to history and handed to the mini
/// player. [opened] is the list item the user tapped (null for links): what it already showed
/// (thumbnail, duration, list texts) is kept.
final class VideoItemConverter extends Converter<VideoDetails, VideoItem> {
  const VideoItemConverter({this.opened});

  final VideoItem? opened;

  @override
  VideoItem convert(VideoDetails input) {
    final opened = this.opened;
    return VideoItem(
      id: input.id,
      title: input.title.isNotEmpty ? input.title : opened?.title ?? '',
      channelName: input.channelName ?? opened?.channelName,
      channelId: input.channelId ?? opened?.channelId,
      channelAvatarUrl: input.channelAvatarUrl ?? opened?.channelAvatarUrl,
      thumbnailUrl: opened?.thumbnailUrl,
      viewsText: opened?.viewsText ?? input.viewsText,
      durationText: opened?.durationText,
      publishedText: opened?.publishedText ?? input.publishedText,
      isLive: opened?.isLive ?? false,
    );
  }
}
