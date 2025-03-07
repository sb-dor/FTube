import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

typedef DownloadingProgress =
    void Function(
      /// [total mb]
      int total,

      /// [total downloaded]
      int downloading,

      /// [percentage of downloaded]
      double progress,
    );

abstract class HttpDownloaderHelper {
  static Future<Uint8List> download(
    String url,
    DownloadingProgress downloadingProgress,
  ) async {
    final completer = Completer<Uint8List>();

    try {
      final client = http.Client();
      final request = http.Request("GET", Uri.parse(url));
      final response = client.send(request);

      int downloadingBytes = 0;
      final List<List<int>> chunkList = [];

      response.asStream().listen((http.StreamedResponse streamedResponse) {
        streamedResponse.stream.listen(
          (chunk) {
            final int contentLength = streamedResponse.contentLength ?? 0;
            final progress = (downloadingBytes / contentLength) * 100;
            downloadingProgress(contentLength, downloadingBytes, progress);

            chunkList.add(chunk);
            downloadingBytes += chunk.length;
          },
          onDone: () {
            final int contentLength = streamedResponse.contentLength ?? 0;
            final progress = (downloadingBytes / contentLength) * 100;
            downloadingProgress(contentLength, downloadingBytes, progress);

            int start = 0;
            final bytes = Uint8List(contentLength);

            for (var each in chunkList) {
              bytes.setRange(start, start + each.length, each);
              start += each.length;
            }

            completer.complete(bytes);
          },
          onError: (error) => completer.completeError(error),
        );
      });
    } catch (_) {}
    return completer.future;
  }
}
