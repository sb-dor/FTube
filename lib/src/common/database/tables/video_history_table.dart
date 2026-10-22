import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/tables/video_columns.dart';

/// Watched videos, newest last.
@DataClassName('VideoHistoryRow')
class VideoHistory extends Table with VideoColumns {
  @override
  String get tableName => 'video_history';
}
