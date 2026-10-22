import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

/// Whether a downloaded file holds sound only or a full video.
enum DownloadMediaType {
  audio,
  video;

  static const _audioExtensions = {
    '.m4a',
    '.mp3',
    '.aac',
    '.opus',
    '.ogg',
    '.oga',
    '.weba',
    '.wav',
    '.flac',
  };

  /// Reads the stored `media_type`; rows written by the old app have none, so the type is
  /// inferred from the file extension of [path].
  static DownloadMediaType resolve(String? stored, String path) => switch (stored) {
    'audio' => audio,
    'video' => video,
    _ => _audioExtensions.contains(p.extension(path).toLowerCase()) ? audio : video,
  };
}

/// A file downloaded into app storage.
@immutable
class DownloadedFile {
  const DownloadedFile({
    required this.id,
    required this.title,
    required this.path,
    required this.mediaType,
    required this.exists,
    this.storedPath,
    this.thumbnailUrl,
    this.channelName,
    this.viewsText,
    this.videoId,
    this.duration,
    this.createdAt,
  });

  /// Database row id.
  final int id;
  final String title;

  /// Where the file is on this device: [storedPath], or where it was found after the app's
  /// storage directory moved (iOS changes it between installs).
  final String path;

  /// The path saved in the database.
  final String? storedPath;
  final DownloadMediaType mediaType;

  /// False when the file is no longer on the device.
  final bool exists;
  final String? thumbnailUrl;
  final String? channelName;
  final String? viewsText;
  final String? videoId;
  final Duration? duration;
  final String? createdAt;

  bool get isAudio => mediaType == DownloadMediaType.audio;

  bool get isVideo => mediaType == DownloadMediaType.video;

  /// Upper-case file extension, e.g. `MP4`; the media type when the path has none.
  String get typeLabel {
    final extension = p.extension(path).replaceFirst('.', '');
    return (extension.isEmpty ? mediaType.name : extension).toUpperCase();
  }

  DownloadedFile copyWith({
    int? id,
    String? title,
    String? path,
    ValueGetter<String?>? storedPath,
    DownloadMediaType? mediaType,
    bool? exists,
    ValueGetter<String?>? thumbnailUrl,
    ValueGetter<String?>? channelName,
    ValueGetter<String?>? viewsText,
    ValueGetter<String?>? videoId,
    ValueGetter<Duration?>? duration,
    ValueGetter<String?>? createdAt,
  }) => DownloadedFile(
    id: id ?? this.id,
    title: title ?? this.title,
    path: path ?? this.path,
    storedPath: storedPath != null ? storedPath() : this.storedPath,
    mediaType: mediaType ?? this.mediaType,
    exists: exists ?? this.exists,
    thumbnailUrl: thumbnailUrl != null ? thumbnailUrl() : this.thumbnailUrl,
    channelName: channelName != null ? channelName() : this.channelName,
    viewsText: viewsText != null ? viewsText() : this.viewsText,
    videoId: videoId != null ? videoId() : this.videoId,
    duration: duration != null ? duration() : this.duration,
    createdAt: createdAt != null ? createdAt() : this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadedFile &&
          other.id == id &&
          other.title == title &&
          other.path == path &&
          other.storedPath == storedPath &&
          other.mediaType == mediaType &&
          other.exists == exists &&
          other.thumbnailUrl == thumbnailUrl &&
          other.channelName == channelName &&
          other.viewsText == viewsText &&
          other.videoId == videoId &&
          other.duration == duration &&
          other.createdAt == createdAt;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    path,
    storedPath,
    mediaType,
    exists,
    thumbnailUrl,
    channelName,
    viewsText,
    videoId,
    duration,
    createdAt,
  );

  @override
  String toString() => 'DownloadedFile($id, $title, $path)';
}
