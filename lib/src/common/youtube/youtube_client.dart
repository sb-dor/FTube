import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:youtube/src/common/model/video_details.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/model/video_page.dart';
import 'package:youtube/src/common/youtube/json_node.dart';
import 'package:youtube/src/common/youtube/video_converters.dart';

/// Reads public YouTube web pages: search results, watch pages, related videos and query
/// suggestions. It holds no paging state: every page carries the token for the next one.
final class YoutubeClient {
  YoutubeClient({required http.Client httpClient, required this._language}) : _http = httpClient;

  final http.Client _http;

  /// Current UI language code (`en`, `ru`); YouTube localizes view counts and dates with it.
  final String Function() _language;

  static const _base = 'https://www.youtube.com';
  static const _clientVersion = '2.20251020.01.00';
  static const _videoConverter = VideoRendererConverter();
  static const _lockupConverter = LockupViewModelConverter();

  Map<String, String> get _headers => {
    'user-agent':
        'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
        'Chrome/130.0.0.0 Safari/537.36',
    'accept-language': _language(),
    // Skips the cookie-consent interstitial served in some regions.
    'cookie': 'CONSENT=YES+cb; SOCS=CAI',
  };

  Map<String, Object?> _context() => {
    'client': {'clientName': 'WEB', 'clientVersion': _clientVersion, 'hl': _language()},
  };

  /// Videos for [query]. [filter] is a YouTube `sp` search parameter (upload date, type,
  /// sort order). Pass the previous page's [continuation] to load the next page.
  Future<VideoPage> search(String query, {String? filter, String? continuation}) async {
    if (continuation != null) {
      final response = await _post('/youtubei/v1/search', {'continuation': continuation});
      final items = response['onResponseReceivedCommands'].list
          .expand((command) => command['appendContinuationItemsAction']['continuationItems'].list)
          .toList();
      return _searchPage(items);
    }
    final uri = Uri.parse('$_base/results').replace(
      queryParameters: {
        'search_query': query,
        'hl': _language(),
        if (filter != null && filter.isNotEmpty) 'sp': filter,
      },
    );
    final data = extractInitialData(await _get(uri));
    final sections =
        data['contents']['twoColumnSearchResultsRenderer']['primaryContents']['sectionListRenderer']['contents']
            .list;
    return _searchPage(sections);
  }

  VideoPage _searchPage(List<JsonNode> sections) {
    final videos = <VideoItem>[];
    String? continuation;
    for (final section in sections) {
      final token = _continuationToken(section);
      if (token != null) continuation = token;
      for (final content in section['itemSectionRenderer']['contents'].list) {
        if (content.has('videoRenderer')) {
          final video = _videoConverter.convert(content);
          if (video != null) videos.add(video);
        } else if (content.has('shelfRenderer')) {
          for (final item
              in content['shelfRenderer']['content']['verticalListRenderer']['items'].list) {
            final video = _videoConverter.convert(item);
            if (video != null) videos.add(video);
          }
        }
      }
    }
    return VideoPage(videos: _distinct(videos), continuation: videos.isEmpty ? null : continuation);
  }

  /// Watch-page details for [videoId], with the first page of related videos.
  Future<VideoDetails> videoDetails(String videoId) async {
    final uri = Uri.parse('$_base/watch')
        .replace(queryParameters: {'v': videoId, 'hl': _language()});
    final data = extractInitialData(await _get(uri));
    final watch = data['contents']['twoColumnWatchNextResults'];
    final contents = watch['results']['results']['contents'].list;
    final primary = contents.firstWhere(
      (c) => c.has('videoPrimaryInfoRenderer'),
      orElse: () => const JsonNode(null),
    )['videoPrimaryInfoRenderer'];
    final secondary = contents.firstWhere(
      (c) => c.has('videoSecondaryInfoRenderer'),
      orElse: () => const JsonNode(null),
    )['videoSecondaryInfoRenderer'];
    final owner = secondary['owner']['videoOwnerRenderer'];
    final likes = primary.find('likeButtonViewModel').find('buttonViewModel')['title'].string;
    return VideoDetails(
      id: videoId,
      title: primary['title'].text ?? '',
      viewsText:
          primary['viewCount']['videoViewCountRenderer']['shortViewCount'].text ??
          primary['viewCount']['videoViewCountRenderer']['viewCount'].text,
      publishedText: primary['dateText'].text,
      channelName: owner['title'].text,
      channelId: owner['navigationEndpoint']['browseEndpoint']['browseId'].string,
      channelAvatarUrl: owner['thumbnail'].largestImageUrl,
      subscribersText: owner['subscriberCountText'].text,
      likesText: likes,
      description: secondary['attributedDescription'].text ?? secondary['description'].text,
      related: _relatedPage(watch['secondaryResults']['secondaryResults']['results'].list),
    );
  }

  /// The next page of related videos for a [continuation] from [videoDetails] or a previous
  /// call.
  Future<VideoPage> related(String continuation) async {
    final response = await _post('/youtubei/v1/next', {'continuation': continuation});
    final items = response['onResponseReceivedEndpoints'].list
        .expand((endpoint) => endpoint['appendContinuationItemsAction']['continuationItems'].list)
        .toList();
    return _relatedPage(items);
  }

  VideoPage _relatedPage(List<JsonNode> items) {
    final flat = <JsonNode>[
      for (final item in items)
        if (item.has('itemSectionRenderer'))
          ...item['itemSectionRenderer']['contents'].list
        else
          item,
    ];
    final videos = <VideoItem>[];
    String? continuation;
    for (final item in flat) {
      continuation = _continuationToken(item) ?? continuation;
      final video = item.has('lockupViewModel')
          ? _lockupConverter.convert(item)
          : item.has('compactVideoRenderer')
          ? _videoConverter.convert(JsonNode({'videoRenderer': item['compactVideoRenderer'].value}))
          : null;
      if (video != null) videos.add(video);
    }
    return VideoPage(videos: _distinct(videos), continuation: videos.isEmpty ? null : continuation);
  }

  /// Search suggestions for a partially typed [query].
  Future<List<String>> suggestions(String query) async {
    if (query.trim().isEmpty) return const [];
    final uri = Uri.https('suggestqueries.google.com', '/complete/search', {
      'client': 'firefox',
      'ie': 'utf-8',
      'oe': 'utf-8',
      'ds': 'yt',
      'hl': _language(),
      'q': query,
    });
    final body = await _get(uri);
    final decoded = JsonNode(jsonDecode(body));
    return [for (final suggestion in decoded[1].list) ?suggestion.string];
  }

  String? _continuationToken(JsonNode node) =>
      node['continuationItemRenderer']['continuationEndpoint']['continuationCommand']['token']
          .string;

  List<VideoItem> _distinct(List<VideoItem> videos) {
    final seen = <String>{};
    return [
      for (final video in videos)
        if (seen.add(video.id)) video,
    ];
  }

  Future<String> _get(Uri uri) async {
    final response = await _http.get(uri, headers: _headers);
    if (response.statusCode != 200) {
      throw http.ClientException('YouTube responded ${response.statusCode}', uri);
    }
    return utf8.decode(response.bodyBytes);
  }

  Future<JsonNode> _post(String path, Map<String, Object?> body) async {
    final uri = Uri.parse('$_base$path?prettyPrint=false');
    final response = await _http.post(
      uri,
      headers: {..._headers, 'content-type': 'application/json'},
      body: jsonEncode({'context': _context(), ...body}),
    );
    if (response.statusCode != 200) {
      throw http.ClientException('YouTube responded ${response.statusCode}', uri);
    }
    return JsonNode(jsonDecode(utf8.decode(response.bodyBytes)));
  }
}
