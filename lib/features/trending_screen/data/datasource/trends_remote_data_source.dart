import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';
import 'package:youtube/youtube_data_api/youtube_data_api.dart';

abstract class TrendsRemoteDataSource {
  Future<List<TrendsVideosModel>> fetchTrendingVideo();

  Future<List<TrendsVideosModel>> fetchTrendingMusic();

  Future<List<TrendsVideosModel>> fetchTrendingGaming();

  Future<List<TrendsVideosModel>> fetchTrendingMovies();
}

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
