import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/home_screen/bloc/cubits/video_category_cubit/main_video_category_cubit.dart';
import 'package:youtube/features/home_screen/data/repo/home_screen_repo_impl.dart';
import 'package:youtube/features/home_screen/data/sources/home_screen_datasource.dart';
import 'package:youtube/features/home_screen/data/sources/home_screen_datasource_impl.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';

final class VideoCategoryCubitFactory
    implements Factory<MainVideoCategoryCubit> {
  final YoutubeDataApi _youtubeDataApi;

  VideoCategoryCubitFactory(this._youtubeDataApi);

  @override
  MainVideoCategoryCubit create() {
    final HomeScreenDatasource homeScreenDatasource = HomeScreenDatasourceImpl(
      _youtubeDataApi,
    );

    final HomeScreenRepo homeScreenRepoImpl = HomeScreenRepoImpl(
      homeScreenDatasource,
    );

    return MainVideoCategoryCubit(homeScreenRepoImpl);
  }
}
