import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/initialization/logic/composition_root/composition_root.dart';
import 'package:youtube/features/trending_screen/bloc/trending_screen_bloc.dart';
import 'package:youtube/features/trending_screen/data/datasource/i_trends_remote_datasource.dart';
import 'package:youtube/features/trending_screen/data/datasource/trends_remote_data_source.dart';
import 'package:youtube/features/trending_screen/data/repository/trends_repository_impl.dart';
import 'package:youtube/features/trending_screen/domain/repository/trends_repository.dart';

final class TrendingScreenBlocFactory implements Factory<TrendingScreenBloc> {
  TrendingScreenBlocFactory({required YoutubeDataApi youtubeDataApi})
    : _youtubeDataApi = youtubeDataApi;

  final YoutubeDataApi _youtubeDataApi;

  @override
  TrendingScreenBloc create() {
    final ITrendsRemoteDatasource trendsRemoteDataSource = TrendsRemoteDataSourceImpl(
      _youtubeDataApi,
    );

    final TrendsRepository trendsRepoImpl = TrendsRepositoryImpl(trendsRemoteDataSource);

    return TrendingScreenBloc(trendsRepoImpl);
  }
}
