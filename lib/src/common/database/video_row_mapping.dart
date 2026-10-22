import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/model/video_item.dart';

/// Converts saved video rows (history, likes, playlist videos) to [VideoItem]s and back.
extension VideoHistoryRowX on VideoHistoryRow {
  VideoItem toVideoItem() => _item(
    videoId,
    title,
    channelName,
    channelThumb,
    videoThumbnailUrl,
    views,
    duration,
    videoDate,
  );
}

extension LikeRowX on LikeRow {
  VideoItem toVideoItem() => _item(
    videoId,
    title,
    channelName,
    channelThumb,
    videoThumbnailUrl,
    views,
    duration,
    videoDate,
  );
}

extension PlaylistVideoRowX on PlaylistVideoRow {
  VideoItem toVideoItem() => _item(
    videoId,
    title,
    channelName,
    channelThumb,
    videoThumbnailUrl,
    views,
    duration,
    videoDate,
  );
}

VideoItem _item(
  String? id,
  String? title,
  String? channelName,
  String? channelThumb,
  String? thumbnail,
  String? views,
  String? duration,
  String? published,
) => VideoItem(
  id: id ?? '',
  title: title ?? '',
  channelName: channelName,
  channelAvatarUrl: channelThumb,
  thumbnailUrl: thumbnail,
  viewsText: views,
  durationText: duration,
  publishedText: published,
);

/// Insert companions for saving a [VideoItem]. `date_time` is the save time.
extension VideoItemRowX on VideoItem {
  VideoHistoryCompanion toHistoryCompanion() => VideoHistoryCompanion.insert(
    videoId: Value(id),
    title: Value(title),
    channelName: Value(channelName),
    channelThumb: Value(channelAvatarUrl),
    videoThumbnailUrl: Value(thumbnail),
    views: Value(viewsText),
    duration: Value(durationText),
    videoDate: Value(publishedText),
    savedAt: Value(DateTime.now().toString()),
  );

  LikesCompanion toLikeCompanion() => LikesCompanion.insert(
    videoId: Value(id),
    title: Value(title),
    channelName: Value(channelName),
    channelThumb: Value(channelAvatarUrl),
    videoThumbnailUrl: Value(thumbnail),
    views: Value(viewsText),
    duration: Value(durationText),
    videoDate: Value(publishedText),
    savedAt: Value(DateTime.now().toString()),
  );

  PlaylistVideosCompanion toPlaylistVideoCompanion(int playlistId) =>
      PlaylistVideosCompanion.insert(
        playlistId: Value(playlistId),
        videoId: Value(id),
        title: Value(title),
        channelName: Value(channelName),
        channelThumb: Value(channelAvatarUrl),
        videoThumbnailUrl: Value(thumbnail),
        views: Value(viewsText),
        duration: Value(durationText),
        videoDate: Value(publishedText),
        savedAt: Value(DateTime.now().toString()),
      );
}
