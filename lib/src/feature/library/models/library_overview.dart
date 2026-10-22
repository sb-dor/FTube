import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

/// Everything the library tab shows.
@immutable
class LibraryOverview {
  const LibraryOverview({
    required this.history,
    required this.playlists,
    required this.downloadsCount,
  });

  /// The most recently watched videos, newest first.
  final List<VideoItem> history;

  /// "Liked videos" (when something is liked) followed by the newest user playlists.
  final List<PlaylistSummary> playlists;

  /// Number of files downloaded into app storage.
  final int downloadsCount;

  /// Whether there is nothing to show at all.
  bool get isEmpty => history.isEmpty && playlists.isEmpty && downloadsCount == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryOverview &&
          listEquals(other.history, history) &&
          listEquals(other.playlists, playlists) &&
          other.downloadsCount == downloadsCount;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(history), Object.hashAll(playlists), downloadsCount);

  @override
  String toString() =>
      'LibraryOverview(history: ${history.length}, playlists: ${playlists.length}, '
      'downloads: $downloadsCount)';
}
