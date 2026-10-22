import 'dart:convert';

import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/youtube/json_node.dart';

/// Converts a search-results `videoRenderer` into a [VideoItem]; null for anything else.
final class VideoRendererConverter extends Converter<JsonNode, VideoItem?> {
  const VideoRendererConverter();

  @override
  VideoItem? convert(JsonNode input) {
    final renderer = input['videoRenderer'];
    final id = renderer['videoId'].string;
    final title = renderer['title'].text;
    if (id == null || title == null) return null;
    final duration = renderer['lengthText'].text;
    final badges = renderer['badges'].list;
    final isLive =
        duration == null ||
        badges.any(
          (badge) => badge['metadataBadgeRenderer']['style'].string == 'BADGE_STYLE_TYPE_LIVE_NOW',
        );
    return VideoItem(
      id: id,
      title: title,
      channelName: renderer['longBylineText'].text ?? renderer['ownerText'].text,
      channelId:
          renderer['longBylineText']['runs'][0]['navigationEndpoint']['browseEndpoint']['browseId']
              .string,
      channelAvatarUrl:
          renderer['channelThumbnailSupportedRenderers']['channelThumbnailWithLinkRenderer']['thumbnail']
              .largestImageUrl,
      thumbnailUrl: renderer['thumbnail'].largestImageUrl,
      viewsText: renderer['shortViewCountText'].text ?? renderer['viewCountText'].text,
      durationText: duration,
      publishedText: renderer['publishedTimeText'].text,
      isLive: isLive,
    );
  }
}

/// Converts a watch-page related `lockupViewModel` into a [VideoItem]; null for playlists, mixes
/// and anything that is not a video.
final class LockupViewModelConverter extends Converter<JsonNode, VideoItem?> {
  const LockupViewModelConverter();

  @override
  VideoItem? convert(JsonNode input) {
    final lockup = input['lockupViewModel'];
    if (lockup['contentType'].string != 'LOCKUP_CONTENT_TYPE_VIDEO') return null;
    final id = lockup['contentId'].string;
    final metadata = lockup['metadata']['lockupMetadataViewModel'];
    final title = metadata['title'].text;
    if (id == null || title == null) return null;
    final rows = metadata['metadata']['contentMetadataViewModel']['metadataRows'].list;
    final firstRow = rows.isEmpty ? const <JsonNode>[] : rows.first['metadataParts'].list;
    final secondRow = rows.length < 2 ? const <JsonNode>[] : rows[1]['metadataParts'].list;
    final thumbnail = lockup['contentImage']['thumbnailViewModel'];
    final badges = thumbnail['overlays'].list
        .expand((overlay) => overlay['thumbnailBottomOverlayViewModel']['badges'].list)
        .toList();
    final duration = badges.isEmpty ? null : badges.first['thumbnailBadgeViewModel']['text'].string;
    final avatar = metadata['image']['decoratedAvatarViewModel']['avatar']['avatarViewModel'];
    return VideoItem(
      id: id,
      title: title,
      channelName: firstRow.isEmpty ? null : firstRow.first['text'].text,
      channelAvatarUrl: avatar['image'].largestImageUrl,
      thumbnailUrl: thumbnail['image'].largestImageUrl,
      viewsText: secondRow.isEmpty ? null : secondRow.first['text'].text,
      publishedText: secondRow.length < 2 ? null : secondRow[1]['text'].text,
      durationText: duration,
      isLive: duration == null || duration.toUpperCase() == 'LIVE',
    );
  }
}
