import 'package:youtube/features/trending_screen/data/models/trends_videos_model.dart';
import 'package:youtube/features/trending_screen/domain/entities/trends_videos.dart';
import 'package:youtube/youtube_data_api/models/video.dart';
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
    return data.map((e) => TrendsVideosModel.fromVideo(e)).toList();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingMovies() {
    // TODO: implement fetchTrendingMovies
    throw UnimplementedError();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingMusic() {
    // TODO: implement fetchTrendingMusic
    throw UnimplementedError();
  }

  @override
  Future<List<TrendsVideosModel>> fetchTrendingVideo() {
    // TODO: implement fetchTrendingVideo
    throw UnimplementedError();
  }
}
