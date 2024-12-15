import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/impl/library_create_playlist_locally/library_create_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/impl/library_get_history_locally/library_get_history_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_liked_video_data_source/impl/library_get_liked_video_data_source_locally/library_get_liked_video_data_source_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/impl/library_get_playlist_locally/library_get_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_video_playlist_data_source/impl/library_get_video_playlist_locally/library_get_video_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/impl/library_save_in_history_locally/library_save_in_history_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_set_video_in_playlist_data_source/impl/library_set_video_in_playlist_locally/library_set_video_in_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/repository/library_screen_repository_impl.dart';

final class PlaylistBlocFactory implements Factory<PlaylistsBloc> {
  final DbFloor _dbFloor;

  PlaylistBlocFactory(this._dbFloor);

  @override
  PlaylistsBloc create() {
    // will rewrite in the future
    final libraryScreenRepo = LibraryScreenRepositoryImpl(
      LibraryCreatePlaylistLocally(_dbFloor),
      LibraryGetPlaylistLocally(_dbFloor),
      LibraryGetHistoryLocally(_dbFloor),
      LibrarySaveInHistoryLocally(_dbFloor),
      LibrarySetVideoInPlaylistLocally(_dbFloor),
      LibraryGetVideoPlaylistLocally(_dbFloor),
      LibraryGetLikedVideoDataSourceLocally(_dbFloor),
    );

    return PlaylistsBloc(libraryScreenRepo);
  }
}
