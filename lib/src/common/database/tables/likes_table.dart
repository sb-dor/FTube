import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/tables/video_columns.dart';

/// Liked videos.
@DataClassName('LikeRow')
class Likes extends Table with VideoColumns {
  @override
  String get tableName => 'likes_table';
}
