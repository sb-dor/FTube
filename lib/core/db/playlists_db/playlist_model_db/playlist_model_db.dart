import 'package:floor/floor.dart';
import 'package:youtube/core/db/playlists_db/playlist_videos_model_db/playlist_videos_model_db.dart';

@Entity(tableName: "playlists")
class PlaylistModelDb {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  final String? name;

  @ignore
  List<PlaylistVideosModelDb>? videos;

  PlaylistModelDb({this.id, this.name, this.videos});
}
