import 'package:youtube/core/db/db_floor.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/library_inner_screens/blocs/playlist_inner_screen_bloc/playlist_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/impl/playlist_inner_screen_data_source_impl.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/playlist_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source_impl/playlist_videos_inner_screen_data_source_impl.dart';
import 'package:youtube/features/library_inner_screens/data/repository/playlist_inner_screen_repository_impl.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository.dart';

final class PlaylistInnerScreenBlocFactory implements Factory<PlaylistInnerScreenBloc> {
  final DbFloor _dbFloor;

  PlaylistInnerScreenBlocFactory(this._dbFloor);

  @override
  PlaylistInnerScreenBloc create() {
    // will be rewrite in the future
    final PlaylistInnerScreenDataSource innerScreenDataSource = PlaylistInnerScreenDataSourceImpl(
      _dbFloor,
    );

    final PlaylistVideosInnerScreenDataSource videosInnerScreenDataSource =
        PlaylistVideosInnerScreenDataSourceImpl(_dbFloor);

    final PlaylistInnerScreenRepository repository = PlaylistInnerScreenRepositoryImpl(
      innerScreenDataSource,
      videosInnerScreenDataSource,
    );

    return PlaylistInnerScreenBloc(repository);
  }
}
