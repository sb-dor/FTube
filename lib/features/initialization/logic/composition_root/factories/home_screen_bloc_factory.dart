import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/home_screen/bloc/main_home_screen_bloc.dart';
import 'package:youtube/features/home_screen/data/repo/home_screen_repo_impl.dart';
import 'package:youtube/features/home_screen/data/sources/home_screen_datasource.dart';
import 'package:youtube/features/home_screen/data/sources/home_screen_datasource_impl.dart';
import 'package:youtube/features/home_screen/domain/repo/home_screen_repo.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';

final class HomeScreenBlocFactory implements Factory<MainHomeScreenBloc> {
  final YoutubeDataApi _youtubeDataApi;

  HomeScreenBlocFactory(this._youtubeDataApi);

  @override
  MainHomeScreenBloc create() {
    final HomeScreenDatasource homeScreenDatasource = HomeScreenDatasourceImpl(_youtubeDataApi);

    final HomeScreenRepo homeScreenRepoImpl = HomeScreenRepoImpl(homeScreenDatasource);

    return MainHomeScreenBloc(homeScreenRepoImpl);
  }
}
