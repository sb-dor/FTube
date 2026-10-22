import 'package:drift/drift.dart';
import 'package:youtube/src/common/database/tables/playlists_table.dart';
import 'package:youtube/src/common/database/tables/video_columns.dart';

/// Videos saved into a playlist.
@DataClassName('PlaylistVideoRow')
class PlaylistVideos extends Table with VideoColumns {
  IntColumn get playlistId => integer()
      .named('play_list_id')
      .nullable()
      .references(Playlists, #id, onUpdate: KeyAction.noAction, onDelete: KeyAction.noAction)();

  @override
  String get tableName => 'playlist_videos';
}
