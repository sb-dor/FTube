import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/library_screen/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_create_playlist_data_source/impl/library_create_playlist_locally/library_create_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_history_data_source/impl/library_get_history_locally/library_get_history_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_liked_video_data_source/impl/library_get_liked_video_data_source_locally/library_get_liked_video_data_source_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_playlist_data_source/impl/library_get_playlist_locally/library_get_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_get_video_playlist_data_source/impl/library_get_video_playlist_locally/library_get_video_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_save_in_history_data_source/impl/library_save_in_history_locally/library_save_in_history_locally.dart';
import 'package:youtube/features/library_screen/data/data_sources/library_set_video_in_playlist_data_source/impl/library_set_video_in_playlist_locally/library_set_video_in_playlist_locally.dart';
import 'package:youtube/features/library_screen/data/repository/library_screen_repository_impl.dart';

final class HistoryBlocFactory implements Factory<HistoryBloc> {
  final DbFloor _dbFloor;

  HistoryBlocFactory(this._dbFloor);

  @override
  HistoryBloc create() {
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

    return HistoryBloc(libraryScreenRepo);
  }
}
