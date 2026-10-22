import 'dart:async';

import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

/// Playlist summary queries shared by the playlists screen and the library tab.
extension PlaylistSummaryQueries on AppDatabase {
  /// User playlists, newest first, each with its video count and newest video's thumbnail.
  Future<List<UserPlaylistSummary>> userPlaylistSummaries({int? limit}) =>
      customSelect(
            'SELECT p.id AS id, p.name AS name, '
            '(SELECT COUNT(*) FROM playlist_videos v WHERE v.play_list_id = p.id) AS video_count, '
            '(SELECT v.videoThumbnailUrl FROM playlist_videos v WHERE v.play_list_id = p.id '
            'ORDER BY v.id DESC LIMIT 1) AS thumbnail, '
            '(SELECT v.videoId FROM playlist_videos v WHERE v.play_list_id = p.id '
            'ORDER BY v.id DESC LIMIT 1) AS video_id '
            'FROM playlists p ORDER BY p.id DESC${limit == null ? '' : ' LIMIT ?'}',
            variables: [if (limit != null) Variable.withInt(limit)],
            readsFrom: {playlists, playlistVideos},
          )
          .map(
            (row) => UserPlaylistSummary(
              id: row.read<int>('id'),
              name: row.readNullable<String>('name') ?? '',
              videoCount: row.read<int>('video_count'),
              thumbnailUrl: _thumbnail(
                row.readNullable<String>('thumbnail'),
                row.readNullable<String>('video_id'),
              ),
            ),
          )
          .get();

  /// The liked videos as a playlist; null when nothing is liked.
  Future<LikedPlaylistSummary?> likedPlaylistSummary() async {
    final row = await customSelect(
      'SELECT COUNT(*) AS video_count, '
      '(SELECT videoThumbnailUrl FROM likes_table ORDER BY id DESC LIMIT 1) AS thumbnail, '
      '(SELECT videoId FROM likes_table ORDER BY id DESC LIMIT 1) AS video_id '
      'FROM likes_table',
      readsFrom: {likes},
    ).getSingle();
    final count = row.read<int>('video_count');
    if (count == 0) return null;
    return LikedPlaylistSummary(
      videoCount: count,
      thumbnailUrl: _thumbnail(
        row.readNullable<String>('thumbnail'),
        row.readNullable<String>('video_id'),
      ),
    );
  }

  /// All playlists: "Liked videos" first (when something is liked), then user playlists, newest
  /// first.
  Future<List<PlaylistSummary>> playlistSummaries({int? limit}) async {
    final liked = await likedPlaylistSummary();
    final user = await userPlaylistSummaries(limit: limit);
    return [?liked, ...user];
  }

  /// Emits [fetch]'s result when listened to and again after every write to [tables].
  ///
  /// Writes that arrive while a fetch runs trigger one more fetch afterwards, so the last value
  /// always reflects the latest data.
  Stream<T> watchTables<T>(
    Iterable<ResultSetImplementation<HasResultSet, Object?>> tables,
    Future<T> Function() fetch,
  ) {
    final controller = StreamController<T>();
    StreamSubscription<Set<TableUpdate>>? updates;
    var running = false;
    var pending = false;

    Future<void> refresh() async {
      if (running) {
        pending = true;
        return;
      }
      running = true;
      try {
        do {
          pending = false;
          final value = await fetch();
          if (controller.isClosed) return;
          controller.add(value);
        } while (pending && !controller.isClosed);
      } on Object catch (error, stackTrace) {
        if (!controller.isClosed) controller.addError(error, stackTrace);
      } finally {
        running = false;
      }
    }

    controller
      ..onListen = () {
        updates = tableUpdates(TableUpdateQuery.onAllTables(tables)).listen((_) => refresh());
        refresh().ignore();
      }
      ..onCancel = () async {
        await updates?.cancel();
        if (!controller.isClosed) controller.close().ignore();
      };
    return controller.stream;
  }
}

String? _thumbnail(String? url, String? videoId) {
  if (url != null && url.isNotEmpty) return url;
  if (videoId == null || videoId.isEmpty) return null;
  return VideoItem(id: videoId, title: '').thumbnail;
}
