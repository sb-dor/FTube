import 'package:drift/drift.dart';

/// Audio and video files downloaded into app storage.
@DataClassName('FileDownloadRow')
class FileDownloads extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Video title.
  TextColumn get name => text().nullable()();

  /// Absolute path of the saved file.
  TextColumn get downloadedPath => text().named('downloaded_path').nullable()();

  /// Thumbnail URL.
  TextColumn get imagePath => text().named('image_path').nullable()();

  TextColumn get views => text().nullable()();

  TextColumn get createdAt => text().named('created_at').nullable()();

  TextColumn get channelName => text().named('channel_name').nullable()();

  /// YouTube video id the file was downloaded from (schema v6).
  TextColumn get videoId => text().named('video_id').nullable()();

  /// `audio` or `video` (schema v6). Older rows are null; readers infer the type from the
  /// file extension.
  TextColumn get mediaType => text().named('media_type').nullable()();

  /// Media length in seconds (schema v6).
  IntColumn get durationSeconds => integer().named('duration_seconds').nullable()();

  @override
  String get tableName => 'file_downloads';
}
