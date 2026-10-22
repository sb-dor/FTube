import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:youtube/src/common/js/js_runtime.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/youtube/challenge_solver.dart';
import 'package:youtube/src/common/youtube/json_node.dart';
import 'package:youtube/src/common/youtube/po_token/po_token_generator.dart';
import 'package:youtube_explode_dart/js_challenge.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

/// Thrown when no client returned any stream for a video.
final class NoStreamsException implements Exception {
  const NoStreamsException(this.videoId, [this.cause]);

  final String videoId;
  final Object? cause;

  @override
  String toString() => 'No streams for $videoId${cause == null ? '' : ': $cause'}';
}

/// Collects a video's streams from several YouTube clients.
///
/// YouTube blocks many streams past their first megabyte unless the request proves it comes from
/// a real player. Sources, best first:
/// 1. web-family clients (web and mobile web with BotGuard PO tokens) whose signature and `n`
///    challenges are solved in the hidden browser page;
/// 2. the Quest VR client;
/// 3. the Android client through youtube_explode.
final class YoutubeStreamsClient {
  YoutubeStreamsClient({
    required this._httpClient,
    required this._youtubeExplode,
    this._poTokens,
    this._solver,
  });

  final http.Client _httpClient;
  final YoutubeExplode _youtubeExplode;
  final PoTokenGenerator? _poTokens;
  final WebViewChallengeSolver? _solver;

  /// YouTube's visitor id, required by the VR client for anonymous requests.
  String? _visitorData;

  static const _vrVersion = '1.65.10';
  static const _vrUserAgent =
      'com.google.android.apps.youtube.vr.oculus/$_vrVersion '
      '(Linux; U; Android 12L; eureka-user Build/SQ3A.220605.009.A1) gzip';
  static const _browserUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/96.0.4664.18 Safari/537.36';

  /// Recent catalogs: playback, preview and download of one video share the same URLs, and
  /// YouTube sees one player request instead of several.
  final _cache = <String, (DateTime, Future<StreamCatalog>)>{};

  /// Every stream of [videoId] with all of its sources, best source first.
  Future<StreamCatalog> catalog(String videoId) {
    final cached = _cache[videoId];
    if (cached != null && DateTime.now().difference(cached.$1) < const Duration(minutes: 30)) {
      return cached.$2;
    }
    final future = _load(videoId);
    _cache[videoId] = (DateTime.now(), future);
    future.ignore();
    future.catchError((Object _) {
      _cache.remove(videoId);
      return StreamCatalog(videoId: videoId, streams: const []);
    }).ignore();
    return future;
  }

  Future<StreamCatalog> _load(String videoId) async {
    Object? lastError;
    Future<List<MediaStream>> guard(Future<List<MediaStream>> Function() load, String name) async {
      try {
        return await load();
      } on Object catch (error, stackTrace) {
        lastError = error;
        l.w('Streams | $name failed for $videoId: $error', stackTrace);
        return const [];
      }
    }

    final results = await Future.wait([
      guard(() => _webStreams(videoId), 'web'),
      guard(() => _vrStreams(videoId), 'ANDROID_VR'),
      guard(() => _explodeStreams(videoId), 'youtube_explode'),
    ]);
    final merged = <String, MediaStream>{};
    for (final stream in results.expand((streams) => streams)) {
      // Audio itags repeat per track (original, dubbed, compressed); keep them apart.
      final key =
          '${stream.kind.name}-${stream.itag}-${stream.isOriginalAudio}-${stream.isDrcAudio}';
      final known = merged[key];
      merged[key] = known == null
          ? stream
          : known.withSources([
              ...known.sources,
              for (final source in stream.sources)
                if (!known.sources.any((s) => s.url == source.url)) source,
            ]);
    }
    if (merged.isEmpty) throw NoStreamsException(videoId, lastError);
    return StreamCatalog(videoId: videoId, streams: merged.values.toList());
  }

  // ---- Web-family clients (WEB, MWEB) ------------------------------------------------------

  static const _webClients = [
    (name: 'WEB', id: '1', version: '', userAgent: JsRuntime.userAgent, poToken: true),
    (
      name: 'MWEB',
      id: '2',
      version: '2.20250925.01.00',
      userAgent:
          'Mozilla/5.0 (iPad; CPU OS 16_7_10 like Mac OS X) AppleWebKit/605.1.15 '
          '(KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1,gzip(gfe)',
      poToken: true,
    ),
  ];

  _WatchConfig? _watchConfig;

  /// Streams from the first web-family client that returns playable ones.
  Future<List<MediaStream>> _webStreams(String videoId) async {
    final solver = _solver;
    if (solver == null) return const [];
    final config = await _config(videoId);
    // WEB often lists only the muxed stream (the rest needs YouTube's SABR protocol); a client
    // wins once it returns separate audio and video streams, otherwise the richest result.
    var best = const <MediaStream>[];
    for (final client in _webClients) {
      final poTokens = _poTokens;
      if (client.poToken && poTokens == null) continue;
      try {
        final streams = await _webClientStreams(videoId, config, client, solver, poTokens);
        if (streams.any((s) => s.kind == MediaStreamKind.audio)) return streams;
        if (streams.length > best.length) best = streams;
      } on Object catch (error) {
        l.w('Streams | ${client.name} failed for $videoId: $error');
      }
    }
    return best;
  }

  Future<List<MediaStream>> _webClientStreams(
    String videoId,
    _WatchConfig config,
    _WebClient client,
    WebViewChallengeSolver solver,
    PoTokenGenerator? poTokens,
  ) async {
    // Web player and streaming tokens are bound to the video id (yt-dlp PO Token Guide).
    final poToken = client.poToken ? await poTokens!.mint(videoId) : null;
    final version = client.version.isEmpty ? config.clientVersion : client.version;
    final response = await _httpClient.post(
      Uri.parse('https://www.youtube.com/youtubei/v1/player?prettyPrint=false'),
      headers: {
        'content-type': 'application/json',
        'user-agent': client.userAgent,
        'x-youtube-client-name': client.id,
        'x-youtube-client-version': version,
        'x-goog-visitor-id': config.visitorData,
        'origin': 'https://www.youtube.com',
        'referer': 'https://www.youtube.com/',
      },
      body: jsonEncode({
        'context': {
          'client': {
            'clientName': client.name,
            'clientVersion': version,
            'hl': 'en',
            'timeZone': 'UTC',
            'utcOffsetMinutes': 0,
            'visitorData': config.visitorData,
          },
        },
        'videoId': videoId,
        'playbackContext': {
          'contentPlaybackContext': {
            'html5Preference': 'HTML5_PREF_WANTS',
            'signatureTimestamp': config.signatureTimestamp,
          },
        },
        'serviceIntegrityDimensions': ?(poToken == null ? null : {'poToken': poToken}),
        'contentCheckOk': true,
        'racyCheckOk': true,
      }),
    );
    if (response.statusCode != 200) {
      throw http.ClientException('${client.name} player responded ${response.statusCode}');
    }
    final data = JsonNode(jsonDecode(utf8.decode(response.bodyBytes)));
    final status = data['playabilityStatus']['status'].string;
    if (status != 'OK') {
      throw http.ClientException(
        '${client.name}: $status ${data['playabilityStatus']['reason'].string ?? ''}',
      );
    }
    final streaming = data['streamingData'];
    final formats = [
      for (final format in streaming['formats'].list) (format, true),
      for (final format in streaming['adaptiveFormats'].list) (format, false),
    ];

    // Collect the challenges of every URL and solve them in one go.
    final pending = <(JsonNode, bool, Uri, String?, String?)>[];
    final signatures = <String>{};
    final ns = <String>{};
    for (final (format, muxed) in formats) {
      Uri? url;
      String? signature;
      String? signatureParam;
      if (format['url'].string case final direct?) {
        url = Uri.tryParse(direct);
      } else if (format['signatureCipher'].string case final cipher?) {
        final parts = Uri.splitQueryString(cipher);
        url = Uri.tryParse(parts['url'] ?? '');
        signature = parts['s'];
        signatureParam = parts['sp'] ?? 'signature';
        if (signature != null) signatures.add(signature);
      }
      if (url == null) continue;
      if (url.queryParameters['n'] case final n?) ns.add(n);
      pending.add((format, muxed, url, signature, signatureParam));
    }
    if (pending.isEmpty) return const [];
    final solved = await solver.solveBulk(config.playerUrl, {
      if (signatures.isNotEmpty) JSChallengeType.sig: signatures.toList(),
      if (ns.isNotEmpty) JSChallengeType.n: ns.toList(),
    });
    final durationMs = int.tryParse(streaming['formats'][0]['approxDurationMs'].string ?? '');
    final streams = <MediaStream>[];
    var unsolved = 0;
    for (final (format, muxed, url, signature, signatureParam) in pending) {
      final parameters = Map<String, String>.of(url.queryParameters);
      if (signature != null) {
        final value = solved[signature];
        if (value == null) {
          unsolved++;
          continue;
        }
        parameters[signatureParam!] = value;
      }
      if (parameters['n'] case final n?) {
        final value = solved[n];
        if (value == null) {
          unsolved++;
          continue;
        }
        parameters['n'] = value;
      }
      if (poToken != null) parameters['pot'] = poToken;
      final finalUrl = url.replace(queryParameters: parameters);
      final stream = _parseFormat(
        format,
        muxed: muxed,
        durationMs: durationMs,
        url: finalUrl,
        source: (url) => StreamSource(
          url: url,
          client: client.name,
          headers: {
            'user-agent': client.userAgent,
            'origin': 'https://www.youtube.com',
            'referer': 'https://www.youtube.com/',
          },
          chunkSize: 10 * 1024 * 1024,
          maxConnections: 1,
        ),
      );
      if (stream != null) streams.add(stream);
    }
    l.i(
      'Streams | ${client.name}: ${streams.length} of ${pending.length} formats for $videoId'
      '${unsolved == 0 ? '' : ' ($unsolved with unsolved challenges)'}',
    );
    return streams;
  }

  /// Player script URL, signature timestamp and visitor id from a watch page (cached).
  Future<_WatchConfig> _config(String videoId) async {
    final cached = _watchConfig;
    if (cached != null && DateTime.now().difference(cached.fetchedAt) < const Duration(hours: 1)) {
      return cached;
    }
    final response = await _httpClient.get(
      Uri.parse('https://www.youtube.com/watch?v=$videoId&bpctr=9999999999&has_verified=1'),
      headers: {
        'user-agent': _browserUserAgent,
        'accept-language': 'en-US,en;q=0.9',
        'cookie': 'CONSENT=YES+cb; SOCS=CAI',
      },
    );
    final html = utf8.decode(response.bodyBytes);
    String? find(String pattern) => RegExp(pattern).firstMatch(html)?.group(1);
    final playerPath = find(r'"(?:PLAYER_JS_URL|jsUrl)":"([^"]+base\.js)"');
    final sts = find(r'"STS":(\d+)') ?? find(r'signatureTimestamp":(\d+)');
    final visitor = find('"VISITOR_DATA":"([^"]+)"');
    final version = find('"INNERTUBE_CLIENT_VERSION":"([^"]+)"');
    if (playerPath == null || sts == null || visitor == null || version == null) {
      throw http.ClientException('Watch page without player configuration');
    }
    return _watchConfig = _WatchConfig(
      playerUrl: playerPath.startsWith('http') ? playerPath : 'https://www.youtube.com$playerPath',
      signatureTimestamp: int.parse(sts),
      visitorData: visitor,
      clientVersion: version,
      fetchedAt: DateTime.now(),
    );
  }

  // ---- ANDROID_VR ------------------------------------------------------------------------------

  Future<List<MediaStream>> _vrStreams(String videoId) async {
    var response = await _vrPlayer(videoId);
    if (response['playabilityStatus']['status'].string != 'OK') {
      // Anonymous VR requests need a visitor id; YouTube hands one out with the refusal.
      final visitor = response['responseContext']['visitorData'].string;
      if (visitor == null || visitor == _visitorData) return const [];
      _visitorData = visitor;
      response = await _vrPlayer(videoId);
      if (response['playabilityStatus']['status'].string != 'OK') return const [];
    }
    final data = response['streamingData'];
    final durationMs = int.tryParse(data['formats'][0]['approxDurationMs'].string ?? '');
    StreamSource source(Uri url) => StreamSource(
      url: url,
      client: 'ANDROID_VR',
      headers: const {'user-agent': _vrUserAgent},
      useRangeHeader: true,
      chunkSize: 10 * 1024 * 1024,
    );
    return [
      for (final format in data['formats'].list)
        ?_parseFormat(format, muxed: true, durationMs: durationMs, source: source),
      for (final format in data['adaptiveFormats'].list)
        ?_parseFormat(format, muxed: false, durationMs: durationMs, source: source),
    ];
  }

  Future<JsonNode> _vrPlayer(String videoId) async {
    final visitor = _visitorData;
    final response = await _httpClient.post(
      Uri.parse('https://www.youtube.com/youtubei/v1/player?prettyPrint=false'),
      headers: {
        'content-type': 'application/json',
        'user-agent': _vrUserAgent,
        'x-youtube-client-name': '28',
        'x-youtube-client-version': _vrVersion,
        'x-goog-visitor-id': ?visitor,
      },
      body: jsonEncode({
        'context': {
          'client': {
            'clientName': 'ANDROID_VR',
            'clientVersion': _vrVersion,
            'deviceMake': 'Oculus',
            'deviceModel': 'Quest 3',
            'androidSdkVersion': 32,
            'userAgent': _vrUserAgent,
            'osName': 'Android',
            'osVersion': '12L',
            'hl': 'en',
            'timeZone': 'UTC',
            'utcOffsetMinutes': 0,
            'visitorData': ?visitor,
          },
        },
        'videoId': videoId,
        'contentCheckOk': true,
        'racyCheckOk': true,
      }),
    );
    if (response.statusCode != 200) {
      throw http.ClientException('Player responded ${response.statusCode}');
    }
    return JsonNode(jsonDecode(utf8.decode(response.bodyBytes)));
  }

  MediaStream? _parseFormat(
    JsonNode format, {
    required bool muxed,
    required int? durationMs,
    required StreamSource Function(Uri url) source,
    Uri? url,
  }) {
    url ??= Uri.tryParse(format['url'].string ?? '');
    final itag = switch (format['itag'].value) {
      final int value => value,
      _ => null,
    };
    final mime = format['mimeType'].string;
    if (url == null || itag == null || mime == null) return null;
    final match = RegExp(r'^(\w+)/(\w+);\s*codecs="([^"]*)"').firstMatch(mime);
    if (match == null) return null;
    final bitrate = switch (format['bitrate'].value) {
      final int value => value,
      _ => 0,
    };
    final size =
        int.tryParse(format['contentLength'].string ?? '') ??
        (durationMs == null ? null : bitrate * durationMs ~/ 8000);
    if (size == null || size == 0) return null;
    final tags = _xtags(url);
    return MediaStream(
      itag: itag,
      kind: muxed
          ? MediaStreamKind.muxed
          : match.group(1) == 'audio'
          ? MediaStreamKind.audio
          : MediaStreamKind.video,
      container: match.group(2)!,
      codecs: match.group(3)!,
      sizeBytes: size,
      bitrate: bitrate,
      qualityLabel: format['qualityLabel'].string,
      height: switch (format['height'].value) {
        final int value => value,
        _ => 0,
      },
      fps: switch (format['fps'].value) {
        final int value => value,
        _ => 0,
      },
      isOriginalAudio: (tags['acont'] ?? 'original') == 'original',
      isDrcAudio: tags['drc'] == '1',
      sources: [source(url)],
    );
  }

  // ---- youtube_explode (Android client) ---------------------------------------------------------

  Future<List<MediaStream>> _explodeStreams(String videoId) async {
    final manifest = await _youtubeExplode.videos.streams.getManifest(videoId);
    return [
      for (final stream in manifest.streams)
        if (stream.fragments.isEmpty && stream.container != StreamContainer.m3u8)
          _fromStreamInfo(stream),
    ];
  }

  MediaStream _fromStreamInfo(StreamInfo stream) {
    final client = stream.url.queryParameters['c'] ?? '';
    // Android client URLs refuse the range query parameter and large ranges.
    final android = client == 'ANDROID';
    final tags = _xtags(stream.url);
    return MediaStream(
      itag: stream.tag,
      kind: switch (stream) {
        MuxedStreamInfo() => MediaStreamKind.muxed,
        AudioOnlyStreamInfo() => MediaStreamKind.audio,
        _ => MediaStreamKind.video,
      },
      container: stream.container.name,
      codecs: switch (stream) {
        final VideoStreamInfo video => video.videoCodec,
        final AudioStreamInfo audio => audio.audioCodec,
        _ => '',
      },
      sizeBytes: stream.size.totalBytes,
      bitrate: stream.bitrate.bitsPerSecond,
      qualityLabel: stream is VideoStreamInfo ? stream.qualityLabel : null,
      height: stream is VideoStreamInfo ? stream.videoResolution.height : 0,
      fps: stream is VideoStreamInfo ? stream.framerate.framesPerSecond.round() : 0,
      isOriginalAudio:
          (tags['acont'] ?? 'original') == 'original' &&
          switch (stream) {
            final AudioOnlyStreamInfo audio => audio.audioTrack?.audioIsDefault ?? true,
            _ => true,
          },
      isDrcAudio: tags['drc'] == '1',
      sources: [
        StreamSource(
          url: stream.url,
          client: client,
          headers: const {'user-agent': _browserUserAgent},
          useRangeHeader: android,
          chunkSize: android ? 1024 * 1024 : 4 * 1024 * 1024,
        ),
      ],
    );
  }

  /// `xtags=acont=original:drc=1:lang=en` → `{acont: original, drc: 1, lang: en}`.
  Map<String, String> _xtags(Uri url) => {
    for (final part in (url.queryParameters['xtags'] ?? '').split(':'))
      if (part.split('=') case [final key, final value]) key: value,
  };
}

extension StreamCatalogX on StreamCatalog {
  /// Muxed MP4 with the best bitrate: the fallback source of sound.
  MediaStream? get bestMuxed =>
      of(MediaStreamKind.muxed)
          .where((s) => s.container == 'mp4')
          .sorted((a, b) => b.bitrate.compareTo(a.bitrate))
          .firstOrNull;
}

typedef _WebClient = ({String name, String id, String version, String userAgent, bool poToken});

/// What web-family player requests need from a watch page.
final class _WatchConfig {
  const _WatchConfig({
    required this.playerUrl,
    required this.signatureTimestamp,
    required this.visitorData,
    required this.clientVersion,
    required this.fetchedAt,
  });

  final String playerUrl;
  final int signatureTimestamp;
  final String visitorData;
  final String clientVersion;
  final DateTime fetchedAt;
}
