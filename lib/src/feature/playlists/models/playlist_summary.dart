import 'package:flutter/foundation.dart';
import 'package:youtube/src/common/localization/localization.dart';

/// A playlist as shown in the library: a user playlist or the virtual "Liked videos" list.
@immutable
sealed class PlaylistSummary {
  const PlaylistSummary({required this.videoCount, this.thumbnailUrl});

  /// Number of videos in the playlist.
  final int videoCount;

  /// Thumbnail of the most recently added video; null for an empty playlist.
  final String? thumbnailUrl;

  /// Display name.
  String title(Localization l10n);
}

/// A playlist the user created.
final class UserPlaylistSummary extends PlaylistSummary {
  const UserPlaylistSummary({
    required this.id,
    required this.name,
    required super.videoCount,
    super.thumbnailUrl,
  });

  final int id;
  final String name;

  @override
  String title(Localization l10n) => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPlaylistSummary &&
          other.id == id &&
          other.name == name &&
          other.videoCount == videoCount &&
          other.thumbnailUrl == thumbnailUrl;

  @override
  int get hashCode => Object.hash(id, name, videoCount, thumbnailUrl);

  @override
  String toString() => 'UserPlaylistSummary($id, $name, $videoCount)';
}

/// The virtual playlist of liked videos.
final class LikedPlaylistSummary extends PlaylistSummary {
  const LikedPlaylistSummary({required super.videoCount, super.thumbnailUrl});

  @override
  String title(Localization l10n) => l10n.playlistsLikedVideos;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikedPlaylistSummary &&
          other.videoCount == videoCount &&
          other.thumbnailUrl == thumbnailUrl;

  @override
  int get hashCode => Object.hash(videoCount, thumbnailUrl);

  @override
  String toString() => 'LikedPlaylistSummary($videoCount)';
}
