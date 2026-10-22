import 'package:youtube/src/common/js/js_runtime.dart';
import 'package:youtube_explode_dart/js_challenge.dart';

/// Solves the player script's signature and `n` challenges with yt-dlp's EJS solver running
/// in the hidden browser page (youtube_explode's own solver needs a Deno binary).
final class WebViewChallengeSolver extends BaseEJSSolver {
  WebViewChallengeSolver({required this._runtime});

  final JsRuntime _runtime;
  Future<void>? _loading;

  @override
  Future<String> executeJavaScript(String jsCode) async {
    await (_loading ??= _loadModules());
    return _runtime.evaluate(jsCode, timeout: const Duration(seconds: 90));
  }

  Future<void> _loadModules() async {
    try {
      await _runtime.load(await EJSBuilder.getJSModules());
    } on Object {
      _loading = null;
      rethrow;
    }
  }
}
