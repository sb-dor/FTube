import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:l/l.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube/src/common/js/js_runtime.dart';
import 'package:youtube/src/common/youtube/json_node.dart';
import 'package:youtube/src/common/youtube/po_token/botguard_script.dart';

/// Thrown when BotGuard attestation fails.
final class PoTokenException implements Exception {
  const PoTokenException(this.message);

  final String message;

  @override
  String toString() => 'PoTokenException: $message';
}

/// Mints YouTube proof-of-origin (PO) tokens with BotGuard running in a [JsRuntime].
///
/// One attestation yields an integrity token valid for several hours; tokens for any number of
/// identifiers (a video id for player requests, the visitor id for streaming) are minted from
/// it until it nears expiry.
final class PoTokenGenerator {
  PoTokenGenerator({required this._httpClient, required this._runtime, required this._preferences});

  final http.Client _httpClient;
  final JsRuntime _runtime;
  final SharedPreferences _preferences;

  /// Request key YouTube's web player uses for BotGuard.
  static const _requestKey = 'O43z0dpjhgX20SCx4KAo';

  /// Where the BotGuard API key read from YouTube's player script is kept.
  static const _apiKeyPreference = 'po_token.api_key';

  String? _apiKey;

  DateTime? _expiresAt;
  Future<void>? _attesting;

  /// Starts attestation in the background so the first token is ready sooner.
  void warmUp() =>
      _ensureAttested().catchError((Object error) => l.w('PoToken | warm-up failed: $error'));

  /// A PO token bound to [identifier].
  Future<String> mint(String identifier) async {
    await _ensureAttested();
    try {
      return await _runtime.evaluate('ftubeBotGuard.mint(${jsonEncode(identifier)})');
    } on JsRuntimeException {
      // The minter can go stale; attest again once.
      _expiresAt = null;
      await _ensureAttested();
      return _runtime.evaluate('ftubeBotGuard.mint(${jsonEncode(identifier)})');
    }
  }

  Future<void> _ensureAttested() {
    final expiresAt = _expiresAt;
    if (expiresAt != null && DateTime.now().isBefore(expiresAt)) return Future.value();
    return _attesting ??= _attest().whenComplete(() => _attesting = null);
  }

  Future<void> _attest() async {
    final stopwatch = Stopwatch()..start();
    // A fresh page each time: BotGuard leaves the document locked to Trusted Types.
    await _runtime.reload();
    await _runtime.load(botGuardScript);
    final challenge = await _challenge();
    final botguardResponse = await _runtime.evaluate(
      'ftubeBotGuard.run(${jsonEncode(challenge)})',
      timeout: const Duration(seconds: 30),
    );
    final integrity = JsonNode(await _post('GenerateIT', [_requestKey, botguardResponse]));
    final token = integrity[0].string;
    final lifetime = switch (integrity[1].value) {
      final int seconds => Duration(seconds: seconds),
      _ => const Duration(hours: 1),
    };
    if (token == null) throw const PoTokenException('No integrity token');
    await _runtime.evaluate('ftubeBotGuard.setIntegrityToken(${jsonEncode(token)})');
    _expiresAt = DateTime.now().add(lifetime - const Duration(minutes: 10));
    l.i('PoToken | attested in ${stopwatch.elapsedMilliseconds} ms, valid for $lifetime');
  }

  /// The BotGuard program to run, with its interpreter script.
  Future<Map<String, Object?>> _challenge() async {
    var data = JsonNode(await _post('Create', [_requestKey]));
    // The challenge is sometimes scrambled: base64 with every byte shifted by 97.
    if (data[1].string case final scrambled?) {
      final bytes = base64.decode(base64.normalize(_standardBase64(scrambled)));
      data = JsonNode(jsonDecode(utf8.decode([for (final b in bytes) (b + 97) & 0xff])));
    } else {
      data = data[0];
    }
    String? firstString(JsonNode node) =>
        node.list.map((n) => n.string).whereType<String>().firstOrNull;
    var interpreter = firstString(data[1]);
    final interpreterUrl = firstString(data[2]);
    if (interpreter == null && interpreterUrl != null) {
      final url = interpreterUrl.startsWith('//') ? 'https:$interpreterUrl' : interpreterUrl;
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {'user-agent': JsRuntime.userAgent},
      );
      interpreter = response.body;
    }
    final program = data[4].string;
    final globalName = data[5].string;
    if (interpreter == null || program == null || globalName == null) {
      throw const PoTokenException('Unexpected BotGuard challenge');
    }
    return {'interpreterJavascript': interpreter, 'program': program, 'globalName': globalName};
  }

  Future<Object?> _post(String method, List<Object?> body) async {
    Future<http.Response> send(String apiKey) => _httpClient.post(
      Uri.parse('https://www.youtube.com/api/jnn/v1/$method'),
      headers: {
        'user-agent': JsRuntime.userAgent,
        'accept': 'application/json',
        'content-type': 'application/json+protobuf',
        'x-goog-api-key': apiKey,
        'x-user-agent': 'grpc-web-javascript/0.1',
      },
      body: jsonEncode(body),
    );

    var response = await send(await _botGuardApiKey());
    if (const {400, 401, 403}.contains(response.statusCode)) {
      // YouTube may have changed the key; read it again from the current player script.
      response = await send(await _botGuardApiKey(refresh: true));
    }
    if (response.statusCode != 200) {
      throw PoTokenException('$method responded ${response.statusCode}');
    }
    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  /// The public API key YouTube's web player sends to BotGuard, read from the player script
  /// (it is not stored in this app's source) and cached between launches.
  Future<String> _botGuardApiKey({bool refresh = false}) async {
    if (!refresh) {
      final known = _apiKey ?? _preferences.getString(_apiKeyPreference);
      if (known != null) return _apiKey = known;
    }
    final headers = {'user-agent': JsRuntime.userAgent, 'cookie': 'CONSENT=YES+cb; SOCS=CAI'};
    final home = await _httpClient.get(Uri.https('www.youtube.com', '/'), headers: headers);
    final playerPath = RegExp(r'"(?:jsUrl|PLAYER_JS_URL)":"([^"]+base\.js)"')
        .firstMatch(utf8.decode(home.bodyBytes))
        ?.group(1);
    if (playerPath == null) throw const PoTokenException('Player script not found');
    final script = await _httpClient.get(
      Uri.parse('https://www.youtube.com$playerPath'),
      headers: headers,
    );
    final key = RegExp(r'X-Goog-Api-Key"\]?:"(AIza[0-9A-Za-z_-]{35})"')
        .firstMatch(utf8.decode(script.bodyBytes))
        ?.group(1);
    if (key == null) throw const PoTokenException('BotGuard API key not found');
    await _preferences.setString(_apiKeyPreference, key);
    return _apiKey = key;
  }

  String _standardBase64(String value) =>
      value.replaceAll('-', '+').replaceAll('_', '/').replaceAll('.', '=');
}
