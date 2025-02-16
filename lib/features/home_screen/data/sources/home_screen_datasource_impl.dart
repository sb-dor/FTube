import 'package:youtube/core/api/api_env.dart';
import 'package:youtube/core/api/api_settings.dart';
import 'package:youtube/core/api/api_urls.dart';
import 'package:youtube/core/models/video_category_models/video_category.dart';
import 'package:youtube/core/utils/constants.dart';
import 'package:youtube/core/youtube_data_api/youtube_data_api.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube/core/youtube_data_api/models/channel.dart' as ytch;
import 'package:youtube/core/youtube_data_api/models/playlist.dart' as ytp;
import 'package:youtube/features/home_screen/data/sources/home_screen_datasource.dart';

final class HomeScreenDatasourceImpl implements HomeScreenDatasource {
  final YoutubeDataApi _youtubeDataApi;

  HomeScreenDatasourceImpl(this._youtubeDataApi);

  @override
  Future<Map<String, dynamic>> homeScreenGetVideo({
    String? q,
    bool clearSearch = false,
  }) async {
    final Map<String, dynamic> res = {};
    try {
      // if (videoCategoryId != null) {
      //   params['videoCategoryId'] = videoCategoryId;
      // }
      //
      // var response = await APISettings.dio.get(search + key + snippetPart, queryParameters: params);

      // if (response.statusCode != Constants.STATUS_SUCCESS) return {'server_error': true};
      // Map<String, dynamic> json = response.data;
      // if (json.containsKey('items')) {
      //   List<dynamic> listItem = json['items'];
      //   List<Video> videos = listItem.map((e) => Video.fromJson(e)).toList();

      final String query = q ?? (await _youtubeDataApi.fetchRandomWord() ?? '');

      // debugPrint"making req: $query");

      final data = await _youtubeDataApi.fetchSearchVideo(
        query,
        YOUTUBE_API_KEY,
        clearLastSearch: clearSearch,
      );

      final List<ytv.Video> videos = [];
      final List<ytch.Channel> channels = [];
      final List<ytp.PlayList> playlist = [];

      for (var each in data) {
        if (each is ytv.Video) {
          videos.add(each);
        } else if (each is ytch.Channel) {
          channels.add(each);
        } else if (each is ytp.PlayList) {
          playlist.add(each);
        }
      }

      res['videos'] = videos;
      res['channels'] = channels;
      res['playlist'] = playlist;
      res['success'] = true;
      // res['next_page_token'] = json['nextPageToken'];
      // res['prev_page_token'] = json['prevPageToken'];
      // }
    } catch (e) {
      res['server_error'] = true;
      // debugPrint"home screen get video error is : $e");
    }
    return res;
  }

  @override
  Future<Map<String, dynamic>> getCategories() async {
    final Map<String, dynamic> res = {};
    try {
      final response = await APISettings.dio.get(
        videoCategories + key + snippetPart + regionCode + languageEn,
      );

      if (response.statusCode != Constants.STATUS_SUCCESS) return {'server_error': true};

      final Map<String, dynamic> json = response.data;

      final List<dynamic> listCat = json['items'];

      final List<VideoCategory> categories = listCat.map((e) => VideoCategory.fromJson(e)).toList();

      res['categories'] = categories;
      res['success'] = true;
      // debugPrint"server categories: $res");
    } catch (e) {
      // debugPrint"getCategories error is $e");
      res['server_error'] = true;
    }
    return res;
  }
}
