import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/impl/playlist_inner_screen_data_source_impl.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/playlist_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source_impl/playlist_videos_inner_screen_data_source_impl.dart';
import 'package:youtube/features/library_inner_screens/data/repository/playlist_inner_screen_repository_impl/playlist_inner_screen_repository_impl.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository/playlist_inner_screen_repository.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/playlist_videos_inner_screen_bloc.dart';

final class PlaylistVideosInnerScreenBlocFactory implements Factory<PlaylistVideosInnerScreenBloc> {
  @override
  PlaylistVideosInnerScreenBloc create() {
    // will be rewrite in the future
    final PlaylistInnerScreenDataSource innerScreenDataSource = PlaylistInnerScreenDataSourceImpl();

    final PlaylistVideosInnerScreenDataSource videosInnerScreenDataSource =
        PlaylistVideosInnerScreenDataSourceImpl();

    final PlaylistInnerScreenRepository repository = PlaylistInnerScreenRepositoryImpl(
      innerScreenDataSource,
      videosInnerScreenDataSource,
    );

    return PlaylistVideosInnerScreenBloc(repository);
  }
}
