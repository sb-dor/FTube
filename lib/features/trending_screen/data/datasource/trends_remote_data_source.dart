import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';

import 'i_trends_remote_datasource.dart';



class TrendsRemoteDataSourceImpl implements ITrendsRemoteDatasource {
  final YoutubeDataApi _youtubeDataApi;

  TrendsRemoteDataSourceImpl(this._youtubeDataApi);

  @override
  Future<List<TrendsVideosModel>> fetchTrendingGaming() async {
    final data = await _youtubeDataApi.fetchTrendingGaming();
    return data.map(TrendsVideosModel.fromEntity).toList();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingMovies() async {
    final data = await _youtubeDataApi.fetchTrendingMovies();
    return data.map(TrendsVideosModel.fromEntity).toList();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingMusic() async {
    final data = await _youtubeDataApi.fetchTrendingMusic();
    return data.map(TrendsVideosModel.fromEntity).toList();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingVideo() async {
    final data = await _youtubeDataApi.fetchTrendingVideo();
    return data.map(TrendsVideosModel.fromEntity).toList();
  }
}
