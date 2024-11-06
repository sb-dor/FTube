import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';

import 'i_trends_remote_datasource.dart';



class TrendsRemoteDataSourceImpl implements TrendsRemoteDataSource {
  final YoutubeDataApi _youtubeDataApi;

  TrendsRemoteDataSourceImpl(this._youtubeDataApi);

  @override
  Future<List<TrendsVideosModel>> fetchTrendingGaming() async {
    var data = await _youtubeDataApi.fetchTrendingGaming();
    return data.map((e) => TrendsVideosModel.fromEntity(e)).toList();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingMovies() async {
    var data = await _youtubeDataApi.fetchTrendingMovies();
    return data.map((e) => TrendsVideosModel.fromEntity(e)).toList();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingMusic() async {
    var data = await _youtubeDataApi.fetchTrendingMusic();
    return data.map((e) => TrendsVideosModel.fromEntity(e)).toList();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingVideo() async {
    var data = await _youtubeDataApi.fetchTrendingVideo();
    return data.map((e) => TrendsVideosModel.fromEntity(e)).toList();
  }
}
