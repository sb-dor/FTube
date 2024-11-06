import 'package:youtube/core/injections/injection_container.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/trending_screen/data/datasource/trends_remote_data_source.dart';
import 'package:youtube/features/trending_screen/data/repository/trends_repository_impl.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';
import 'package:youtube/features/trending_screen/presentation/bloc/trending_screen_bloc.dart';

abstract class TrendsInj {
  static Future<void> trendsInj() async {
    final trendsRemoteDataSource = TrendsRemoteDataSourceImpl(locator<YoutubeDataApi>());

    final trendsRepoImpl = TrendsRepositoryImpl(trendsRemoteDataSource);

    locator.registerFactory<TrendingScreenBloc>(
      () => TrendingScreenBloc(trendsRepoImpl),
    );
  }
}
