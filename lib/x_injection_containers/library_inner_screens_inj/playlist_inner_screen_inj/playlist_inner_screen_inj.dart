import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/impl/playlist_inner_screen_data_source_impl.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_inner_screen_data_source/playlist_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source.dart';
import 'package:youtube/features/library_inner_screens/data/data_source/playlist_videos_inner_screen_data_source/playlist_videos_inner_screen_data_source_impl/playlist_videos_inner_screen_data_source_impl.dart';
import 'package:youtube/features/library_inner_screens/data/repository/playlist_inner_screen_repository_impl/playlist_inner_screen_repository_impl.dart';
import 'package:youtube/features/library_inner_screens/domain/repository/playlist_inner_screen_repository/playlist_inner_screen_repository.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_inner_screen_bloc/playlist_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/playlist_videos_inner_screen_bloc.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

abstract class PlaylistInnerScreenInj {
  static Future<void> playlistInnerScreenInj() async {
    locator.registerLazySingleton<PlaylistInnerScreenDataSource>(
      () => PlaylistInnerScreenDataSourceImpl(),
    );

    locator.registerLazySingleton<PlaylistVideosInnerScreenDataSource>(
      () => PlaylistVideosInnerScreenDataSourceImpl(),
    );

    locator.registerLazySingleton<PlaylistInnerScreenRepository>(
      () => PlaylistInnerScreenRepositoryImpl(
        locator<PlaylistInnerScreenDataSource>(),
        locator<PlaylistVideosInnerScreenDataSource>(),
      ),
    );

    locator.registerFactory<PlaylistInnerScreenBloc>(
      () => PlaylistInnerScreenBloc(
        locator<PlaylistInnerScreenRepository>(),
      ),
    );

    locator.registerFactory<PlaylistVideosInnerScreenBloc>(
      () => PlaylistVideosInnerScreenBloc(
        locator<PlaylistInnerScreenRepository>(),
      ),
    );
  }
}
