import 'package:get_it/get_it.dart';
import 'package:youtube/features/trending_screen/data/datasource/trends_remote_data_source.dart';
import 'package:youtube/features/trending_screen/data/repository/trends_repository_impl.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/trending_screen/presentation/pages/trending_screen.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

import 'features/trending_screen/domain/repository/trends_repository.dart';

final locator = GetIt.instance;

Future<void> initGetIt() async {
  locator.registerLazySingleton<YoutubeDataApi>(() => YoutubeDataApi());
  // trending screen initialization:

  locator.registerLazySingleton<TrendsRemoteDataSource>(
    () => TrendsRemoteDataSourceImpl(locator<YoutubeDataApi>()),
  );

  locator.registerLazySingleton<TrendsRepository>(
    () => TrendsRepositoryImpl(locator<TrendsRemoteDataSource>()),
  );

  locator.registerFactory<TrendingScreenBloc>(
    () => TrendingScreenBloc(locator<TrendsRepository>()),
  );

  //
}
