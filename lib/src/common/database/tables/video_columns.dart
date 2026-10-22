import 'package:drift/drift.dart';

/// Video snapshot columns shared by the history, likes and playlist-videos tables.
///
/// Names match the original Floor schema, so existing databases open unchanged.
mixin VideoColumns on Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get videoId => text().named('videoId').nullable()();

  TextColumn get videoThumbnailUrl => text().named('videoThumbnailUrl').nullable()();

  TextColumn get views => text().named('views').nullable()();

  TextColumn get duration => text().named('duration').nullable()();

  TextColumn get title => text().named('title').nullable()();

  TextColumn get channelName => text().named('channelName').nullable()();

  TextColumn get channelThumb => text().named('channelThumb').nullable()();

  TextColumn get videoDate => text().named('videoDate').nullable()();

  /// When the row was saved, as `DateTime.toString()`.
  TextColumn get savedAt => text().named('date_time').nullable()();
}
