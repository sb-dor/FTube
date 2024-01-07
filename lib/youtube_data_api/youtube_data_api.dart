library youtube_data_api;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:youtube/api/api_settings.dart';
import 'package:collection/collection.dart';
import 'package:xml2json/xml2json.dart';
import 'package:youtube/youtube_data_api/helpers/helpers_extension.dart';
import 'dart:convert';
import 'helpers/extract_json.dart';
import 'models/channel.dart';
import 'models/channel_data.dart';
import 'models/playlist.dart';
import 'models/video.dart';
import 'models/video_data.dart';
import 'models/video_page.dart';

class YoutubeDataApi {
  static YoutubeDataApi? _instance;

  static YoutubeDataApi get instance => _instance ??= YoutubeDataApi._();

  YoutubeDataApi._();

  ///Continue token for load more videos on youtube search
  String? _searchToken;

  ///Continue token for load more videos on youtube channel
  String? _channelToken;

  ///Continue token for load more videos on youtube playlist
  String? _playListToken;

  ///Last search query on youtube search
  String? lastQuery;

  ///Get list of videos and playlists and channels from youtube search with query
  Future<List> fetchSearchVideo(String query, String apiKey, {bool clearLastSearch = false}) async {
    List list = [];
    List<Map<String, dynamic>> contentList = [];

    ///Check if new search query is the same of last search query and continue token is not null
    ///for load more videos with the search query

    if (clearLastSearch) lastQuery = null;

    debugPrint("search token : $_searchToken");
    debugPrint("query : $query");
    debugPrint("lastQuery : $lastQuery");

    if (_searchToken != null && query == lastQuery) {
      var url = 'https://www.youtube.com/youtubei/v1/search?key=$apiKey';
      debugPrint("working first query");
      var body = {
        'context': const {
          'client': {'hl': 'en', 'clientName': 'WEB', 'clientVersion': '2.20200911.04.00'}
        },
        'continuation': _searchToken
      };
      var raw = await Dio().post(url, data: body);
      Map<String, dynamic> jsonMap = raw.data;
      var contents = jsonMap
          .getList('onResponseReceivedCommands')
          ?.firstOrNull
          ?.get('appendContinuationItemsAction')
          ?.getList('continuationItems')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents');
      contentList = (contents ?? []).toList();
      _searchToken = _getContinuationToken(jsonMap);
    } else {
      debugPrint("working second query");
      lastQuery = query;
      var response = await Dio().get(
        'https://www.youtube.com/results?search_query=$query',
      );
      var jsonMap = _getJsonMap(response);
      if (jsonMap != null) {
        var contents = jsonMap
            .get('contents')
            ?.get('twoColumnSearchResultsRenderer')
            ?.get('primaryContents')
            ?.get('sectionListRenderer')
            ?.getList('contents')
            ?.firstOrNull
            ?.get('itemSectionRenderer')
            ?.getList('contents');

        contentList = (contents ?? []).toList();
        _searchToken = _getContinuationToken(jsonMap);
      }
    }
    for (var element in contentList) {
      if (element.containsKey('videoRenderer')) {
        ///Element is Video
        Video video = Video.fromMap(element);
        list.add(video);
      } else if (element.containsKey('channelRenderer')) {
        ///Element is Channel
        Channel channel = Channel.fromMap(element);
        list.add(channel);
      } else if (element.containsKey('playlistRenderer')) {
        ///Element is Playlist
        PlayList playList = PlayList.fromMap(element);
        list.add(playList);
      }
    }
    return list;
  }

  ///Get list of trending videos on youtube
  Future<List<Video>> fetchTrendingVideo() async {
    List<Video> list = [];
    var response = await Dio().get(
      'https://www.youtube.com/feed/trending',
    );
    var raw = response.data;
    var root = parser.parse(raw);
    final scriptText = root.querySelectorAll('script').map((e) => e.text).toList(growable: false);
    var initialData = scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText.firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var firstList = contents != null ? contents.toList() : [];
      var secondContents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.elementAtSafe(3)
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var secondList = secondContents != null ? secondContents.toList() : [];
      var contentList = [...firstList, ...secondList];
      for (var element in contentList) {
        Video video = Video.fromMap(element);
        list.add(video);
      }
    }
    return list;
  }

  ///Get list of trending music videos on youtube
  Future<List<Video>> fetchTrendingMusic() async {
    String params = "4gINGgt5dG1hX2NoYXJ0cw%3D%3D";
    List<Video> list = [];
    var response = await Dio().get(
      'https://www.youtube.com/feed/trending?bp=$params',
    );
    var raw = response.data;
    var root = parser.parse(raw);
    final scriptText = root.querySelectorAll('script').map((e) => e.text).toList(growable: false);
    var initialData = scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText.firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(1)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var contentList = contents != null ? contents.toList() : [];
      for (var element in contentList) {
        Video video = Video.fromMap(element);
        list.add(video);
      }
    }
    return list;
  }

  ///Get list of trending gaming videos on youtube
  Future<List<Video>> fetchTrendingGaming() async {
    String params = "4gIcGhpnYW1pbmdfY29ycHVzX21vc3RfcG9wdWxhcg";
    List<Video> list = [];
    var response = await Dio().get(
      'https://www.youtube.com/feed/trending?bp=$params',
    );
    var raw = response.data;
    var root = parser.parse(raw);
    final scriptText = root.querySelectorAll('script').map((e) => e.text).toList(growable: false);
    var initialData = scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText.firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(2)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var contentList = contents != null ? contents.toList() : [];

      for (var element in contentList) {
        Video video = Video.fromMap(element);
        list.add(video);
      }
    }
    return list;
  }

  Future<List<Video>> fetchTrendingMovies() async {
    String params = "4gIKGgh0cmFpbGVycw%3D%3D";
    List<Video> list = [];
    var response = await Dio().get(
      'https://www.youtube.com/feed/trending?bp=$params',
    );
    var raw = response.data;
    var root = parser.parse(raw);
    final scriptText = root.querySelectorAll('script').map((e) => e.text).toList(growable: false);
    var initialData = scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText.firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.elementAtSafe(3)
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('shelfRenderer')
          ?.get('content')
          ?.get('expandedShelfContentsRenderer')
          ?.getList('items');
      var contentList = contents != null ? contents.toList() : [];
      for (var element in contentList) {
        Video video = Video.fromMap(element);
        list.add(video);
      }
    }
    return list;
  }

  ///Get list of suggestions search queries
  Future<List<String>> fetchSuggestions(String query) async {
    List<String> suggestions = [];
    String baseUrl = 'http://suggestqueries.google.com/complete/search?output=toolbar&ds=yt&q=';
    final myTranformer = Xml2Json();
    var response = await Dio().get(baseUrl + query);
    var body = response.data;
    myTranformer.parse(body);
    var json = myTranformer.toGData();
    List suggestionsData = jsonDecode(json)['toplevel']['CompleteSuggestion'] ?? [];
    for (var suggestion in suggestionsData) {
      suggestions.add(suggestion['suggestion']['data'].toString());
    }
    return suggestions;
  }

  Future<String?> fetchRandomWord() async {
    String? res;
    try {
      var response = await Dio().get('https://random-word-api.herokuapp.com/word');

      if (response.statusCode != 200) return "random";

      List<dynamic> list = response.data;

      res = list.first.toString();
    } catch (e) {
      return "random";
    }
    return res;
  }

  ///Get channel data and videos in channel page
  Future<ChannelData?> fetchChannelData(String channelId) async {
    var response = await Dio().get(
      'https://www.youtube.com/channel/$channelId/videos',
    );
    var raw = response.data;
    var root = parser.parse(raw);
    final scriptText = root.querySelectorAll('script').map((e) => e.text).toList(growable: false);
    var initialData = scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText.firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      ChannelData channelData = ChannelData.fromMap(jsonMap);
      _channelToken = _getContinuationToken(jsonMap);
      return channelData;
    }
    return null;
  }

  ///Get videos from playlist
  Future<List<Video>> fetchPlayListVideos(String id, int loaded) async {
    List<Video> videos = [];
    var url = 'https://www.youtube.com/playlist?list=$id&hl=en&persist_hl=1';
    var response = await Dio().get(
      url,
    );
    var jsonMap = _getJsonMap(response);
    if (jsonMap != null) {
      var contents = jsonMap
          .get('contents')
          ?.get('twoColumnBrowseResultsRenderer')
          ?.getList('tabs')
          ?.firstOrNull
          ?.get('tabRenderer')
          ?.get('content')
          ?.get('sectionListRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('itemSectionRenderer')
          ?.getList('contents')
          ?.firstOrNull
          ?.get('playlistVideoListRenderer')
          ?.getList('contents');
      var contentList = contents!.toList();
      for (var element in contentList) {
        Video video = Video.fromMap(element);
        videos.add(video);
      }
      _playListToken = _getPlayListContinuationToken(jsonMap);
    }
    return videos;
  }

  ///Get video data (videoId, title, viewCount, username, likeCount, unlikeCount, channelThumb,
  /// channelId, subscribeCount ,Related videos)
  Future<VideoData?> fetchVideoData(String videoId) async {
    VideoData? videoData;
    var response = await Dio().get('https://www.youtube.com/watch?v=$videoId');
    var raw = response.data;
    var root = parser.parse(raw);
    final scriptText = root.querySelectorAll('script').map((e) => e.text).toList(growable: false);
    var initialData = scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText.firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    if (jsonMap != null) {
      var contents = jsonMap.get('contents')?.get('twoColumnWatchNextResults');

      var contentList =
          contents?.get('secondaryResults')?.get('secondaryResults')?.getList('results')?.toList();

      List<Video> videosList = [];

      contentList?.forEach((element) {
        if (element['compactVideoRenderer']?['title']?['simpleText'] != null) {
          Video video = Video.fromMap(element);
          videosList.add(video);
        }
      });

      videoData = VideoData(video: VideoPage.fromMap(contents, videoId), videosList: videosList);
    }
    return videoData;
  }

  ///Load more videos in youtube channel
  Future<List<Video>> loadMoreInChannel(String apiKey) async {
    List<Video> videos = [];
    var client = http.Client();
    var url = 'https://www.youtube.com/youtubei/v1/browse?key=$apiKey';
    var body = {
      'context': const {
        'client': {'hl': 'en', 'clientName': 'WEB', 'clientVersion': '2.20200911.04.00'}
      },
      'continuation': _channelToken
    };
    var raw = await client.post(Uri.parse(url), body: json.encode(body));
    Map<String, dynamic> jsonMap = json.decode(raw.body);
    var contents = jsonMap
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems');
    if (contents != null) {
      var contentList = contents.toList();
      for (var element in contentList) {
        Video video = Video.fromMap(element);
        videos.add(video);
      }
      _channelToken = _getChannelContinuationToken(jsonMap);
    }
    return videos;
  }

  ///Load more videos in youtube playlist
  Future<List<Video>> loadMoreInPlayList(String apiKey) async {
    List<Video> list = [];
    var client = http.Client();
    var url = 'https://www.youtube.com/youtubei/v1/browse?key=$apiKey';
    var body = {
      'context': const {
        'client': {'hl': 'en', 'clientName': 'WEB', 'clientVersion': '2.20200911.04.00'}
      },
      'continuation': _playListToken
    };
    var raw = await client.post(Uri.parse(url), body: json.encode(body));
    Map<String, dynamic> jsonMap = json.decode(raw.body);
    var contents = jsonMap
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems');
    if (contents != null) {
      var contentList = contents.toList();
      for (var element in contentList) {
        Video video = Video.fromMap(element);
        list.add(video);
      }
      _playListToken = _getChannelContinuationToken(jsonMap);
    }
    return list;
  }

  String? _getChannelContinuationToken(Map<String, dynamic>? root) {
    return root!
        .getList('onResponseReceivedActions')
        ?.firstOrNull
        ?.get('appendContinuationItemsAction')
        ?.getList('continuationItems')
        ?.elementAtSafe(30)
        ?.get('continuationItemRenderer')
        ?.get('continuationEndpoint')
        ?.get('continuationCommand')
        ?.getT<String>('token');
  }

  String? _getPlayListContinuationToken(Map<String, dynamic>? root) {
    return root!
        .get('contents')
        ?.get('twoColumnBrowseResultsRenderer')
        ?.getList('tabs')
        ?.firstOrNull
        ?.get('tabRenderer')
        ?.get('content')
        ?.get('sectionListRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('itemSectionRenderer')
        ?.getList('contents')
        ?.firstOrNull
        ?.get('playlistVideoListRenderer')
        ?.getList('contents')
        ?.elementAtSafe(100)
        ?.get('continuationItemRenderer')
        ?.get('continuationEndpoint')
        ?.get('continuationCommand')
        ?.getT<String>('token');
  }

  String? _getContinuationToken(Map<String, dynamic>? root) {
    if (root?['contents'] != null) {
      if (root?['contents']?['twoColumnBrowseResultsRenderer'] != null) {
        return root!
            .get('contents')
            ?.get('twoColumnBrowseResultsRenderer')
            ?.getList('tabs')
            ?.elementAtSafe(1)
            ?.get('tabRenderer')
            ?.get('content')
            ?.get('sectionListRenderer')
            ?.getList('contents')
            ?.firstOrNull
            ?.get('itemSectionRenderer')
            ?.getList('contents')
            ?.firstOrNull
            ?.get('gridRenderer')
            ?.getList('items')
            ?.elementAtSafe(30)
            ?.get('continuationItemRenderer')
            ?.get('continuationEndpoint')
            ?.get('continuationCommand')
            ?.getT<String>('token');
      }
      var contents = root!
          .get('contents')
          ?.get('twoColumnSearchResultsRenderer')
          ?.get('primaryContents')
          ?.get('sectionListRenderer')
          ?.getList('contents');

      if (contents == null || contents.length <= 1) {
        return null;
      }
      return contents
          .elementAtSafe(1)
          ?.get('continuationItemRenderer')
          ?.get('continuationEndpoint')
          ?.get('continuationCommand')
          ?.getT<String>('token');
    }
    if (root?['onResponseReceivedCommands'] != null) {
      return root!
          .getList('onResponseReceivedCommands')
          ?.firstOrNull
          ?.get('appendContinuationItemsAction')
          ?.getList('continuationItems')
          ?.elementAtSafe(1)
          ?.get('continuationItemRenderer')
          ?.get('continuationEndpoint')
          ?.get('continuationCommand')
          ?.getT<String>('token');
    }
    return null;
  }

  Map<String, dynamic>? _getJsonMap(Response response) {
    var raw = response.data;
    var root = parser.parse(raw);
    final scriptText = root.querySelectorAll('script').map((e) => e.text).toList(growable: false);
    var initialData = scriptText.firstWhereOrNull((e) => e.contains('var ytInitialData = '));
    initialData ??= scriptText.firstWhereOrNull((e) => e.contains('window["ytInitialData"] ='));
    var jsonMap = extractJson(initialData!);
    return jsonMap;
  }
}
