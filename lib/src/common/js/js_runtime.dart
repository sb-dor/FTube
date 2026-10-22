import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:l/l.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Thrown when JavaScript in the [JsRuntime] fails.
final class JsRuntimeException implements Exception {
  const JsRuntimeException(this.message);

  final String message;

  @override
  String toString() => 'JsRuntimeException: $message';
}

/// A hidden browser page used as a JavaScript engine.
///
/// YouTube needs two things only a browser can do: BotGuard attestation (for PO tokens) and
/// solving the player script's signature and `n` challenges. Both run here. The page is
/// mounted invisibly by [JsRuntimeHost] so the platform view stays alive.
final class JsRuntime {
  JsRuntime({required this.name}) {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent(userAgent)
      ..addJavaScriptChannel(_channel, onMessageReceived: _onMessage)
      ..setOnConsoleMessage((message) {
        if (message.level == JavaScriptLogLevel.error) l.w('JsRuntime | ${message.message}');
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          // Scripts may assign `location` (yt-dlp's solver does); the page must stay put.
          onNavigationRequest: (request) =>
              _loading ? NavigationDecision.navigate : NavigationDecision.prevent,
          onPageFinished: (url) {
            _loading = false;
            l.d('JsRuntime | $name page loaded ($url)');
            if (!_ready.isCompleted) _ready.complete();
          },
          onWebResourceError: (error) => l.w('JsRuntime | ${error.description}'),
        ),
      );
  }

  /// Browser identity used by the page and by requests made on its behalf.
  static const userAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/131.0.0.0 Safari/537.36';

  static const _channel = 'FTubeBridge';

  /// For logs.
  final String name;

  late final WebViewController controller;
  var _ready = Completer<void>();

  static const _blankPage =
      '<!DOCTYPE html><html><head><meta charset="utf-8"></head><body></body></html>';
  static const _baseUrl = 'https://www.youtube.com/';
  final _pending = <int, Completer<String>>{};
  var _nextId = 0;
  bool _started = false;

  /// True while one of our own page loads is in flight.
  bool _loading = false;

  /// Loads the blank page (on youtube.com's origin, as BotGuard expects).
  Future<void> start() async {
    if (_started) return _ready.future;
    _started = true;
    _loading = true;
    await controller.loadHtmlString(_blankPage, baseUrl: _baseUrl);
    await _ready.future.timeout(const Duration(seconds: 20));
  }

  /// Loads a fresh blank page, dropping everything defined in the old one.
  Future<void> reload() async {
    if (!_started) return start();
    _ready = Completer<void>();
    _loading = true;
    await controller.loadHtmlString(_blankPage, baseUrl: _baseUrl);
    await _ready.future.timeout(const Duration(seconds: 20));
  }

  /// Runs [script] in the page's global scope, e.g. to define functions.
  Future<void> load(String script) async {
    await start();
    await controller.runJavaScript(script);
  }

  /// Evaluates [expression] (a value or a Promise) and returns the resulting string; any other
  /// value is returned JSON-encoded.
  Future<String> evaluate(
    String expression, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await start();
    final id = _nextId++;
    final completer = Completer<String>();
    _pending[id] = completer;
    await controller.runJavaScript('''
(async () => {
  try {
    const value = await ($expression);
    $_channel.postMessage(JSON.stringify({id: $id, ok: true,
      value: typeof value === 'string' ? value : JSON.stringify(value)}));
  } catch (e) {
    $_channel.postMessage(JSON.stringify({id: $id, ok: false, error: String((e && e.stack) || e)}));
  }
})();''');
    try {
      return await completer.future.timeout(timeout);
    } finally {
      _pending.remove(id);
    }
  }

  void _onMessage(JavaScriptMessage message) {
    final data = jsonDecode(message.message);
    if (data is! Map<String, Object?>) return;
    final id = data['id'];
    final completer = id is int ? _pending[id] : null;
    if (completer == null || completer.isCompleted) return;
    if (data['ok'] == true) {
      completer.complete(data['value'] as String? ?? '');
    } else {
      completer.completeError(JsRuntimeException('${data['error']}'));
    }
  }
}

/// Keeps [JsRuntime] pages attached as 1×1 views underneath the app.
class JsRuntimeHost extends StatelessWidget {
  const JsRuntimeHost({required this.runtimes, required this.child, super.key});

  final List<JsRuntime> runtimes;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      for (final runtime in runtimes)
        Positioned(
          left: 0,
          top: 0,
          width: 1,
          height: 1,
          child: IgnorePointer(child: WebViewWidget(controller: runtime.controller)),
        ),
      Positioned.fill(child: child),
    ],
  );
}
