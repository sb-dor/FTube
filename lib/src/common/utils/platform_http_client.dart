import 'dart:io';

import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

CronetEngine? _cronetEngine;

/// An HTTP client on the platform's own network stack: Cronet (Chrome's) on Android and
/// URLSession on iOS.
///
/// YouTube's video servers judge clients partly by their TLS fingerprint; Dart's own stack is
/// refused where the system media player, using the platform stack, is served.
http.Client createPlatformHttpClient() {
  if (Platform.isAndroid) {
    final engine = _cronetEngine ??= CronetEngine.build(
      cacheMode: CacheMode.disabled,
      enableHttp2: true,
      enableQuic: true,
      enableBrotli: true,
    );
    return CronetClient.fromCronetEngine(engine);
  }
  if (Platform.isIOS || Platform.isMacOS) {
    return CupertinoClient.fromSessionConfiguration(
      URLSessionConfiguration.ephemeralSessionConfiguration(),
    );
  }
  return IOClient();
}
