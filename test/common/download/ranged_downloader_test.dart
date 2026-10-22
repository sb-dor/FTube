import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:youtube/src/common/download/ranged_downloader.dart';
import 'package:youtube/src/common/model/media_stream.dart';

/// Serves [content] honouring googlevideo's `range=from-to` parameter or a Range header.
/// Paths starting with `/refuse` answer 403 after [allowedBytes] bytes; requests larger than
/// [maxRange] answer 403 too.
Future<(HttpServer, List<String>)> _serve(
  Uint8List content, {
  bool Function(int requestIndex)? failRequest,
  int allowedBytes = 0,
  int? maxRange,
}) async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
  final log = <String>[];
  var requests = 0;
  server.listen((request) async {
    final index = requests++;
    final rangeText =
        request.uri.queryParameters['range'] ??
        request.headers.value('range')!.replaceFirst('bytes=', '');
    final parts = rangeText.split('-');
    final openEnded = parts[1].isEmpty;
    final end = openEnded ? content.length - 1 : int.parse(parts[1]);
    final range = [int.parse(parts[0]), end];
    log.add('${request.uri.path} $rangeText ${request.headers.value('user-agent')}');
    final refused =
        (request.uri.path.startsWith('/refuse') && range[1] >= allowedBytes) ||
        (request.uri.path == '/progressive-only' && !openEnded) ||
        (maxRange != null && range[1] - range[0] + 1 > maxRange);
    if (refused) {
      request.response.statusCode = HttpStatus.forbidden;
    } else if (failRequest?.call(index) ?? false) {
      request.response.statusCode = HttpStatus.serviceUnavailable;
    } else {
      request.response.add(content.sublist(range[0], range[1] + 1));
    }
    await request.response.close();
  });
  return (server, log);
}

void main() {
  late Directory dir;
  final content = Uint8List.fromList(List.generate(1000003, (i) => (i * 31) % 256));

  setUp(() => dir = Directory.systemTemp.createTempSync('ranged_downloader_test'));
  tearDown(() => dir.deleteSync(recursive: true));

  RangedDownloader downloader() =>
      RangedDownloader(createClient: http.Client.new, chunkSize: 100000, connections: 4);

  StreamSource source(HttpServer server, String path, {bool header = false, int? chunk}) =>
      StreamSource(
        url: Uri.parse('http://${server.address.host}:${server.port}$path?id=1'),
        client: path,
        headers: {'user-agent': 'agent$path'},
        useRangeHeader: header,
        chunkSize: chunk ?? 4 * 1024 * 1024,
      );

  test('writes every byte at its offset and reports full progress', () async {
    final (server, _) = await _serve(content);
    final target = File('${dir.path}/out.bin');
    var progress = 0;
    await downloader().download(
      sources: [source(server, '/videoplayback')],
      totalBytes: content.length,
      target: target,
      cancellation: DownloadCancellation(),
      onProgress: (bytes) => progress = bytes,
    );
    await server.close(force: true);
    expect(target.readAsBytesSync(), content);
    expect(progress, content.length);
  });

  test('retries a request that failed', () async {
    final (server, _) = await _serve(content, failRequest: (index) => index == 2);
    final target = File('${dir.path}/out.bin');
    await downloader().download(
      sources: [source(server, '/videoplayback')],
      totalBytes: content.length,
      target: target,
      cancellation: DownloadCancellation(),
    );
    await server.close(force: true);
    expect(target.readAsBytesSync(), content);
  });

  test('sends a Range header and the source headers when asked', () async {
    final (server, log) = await _serve(content);
    final target = File('${dir.path}/out.bin');
    await downloader().download(
      sources: [source(server, '/videoplayback', header: true)],
      totalBytes: content.length,
      target: target,
      cancellation: DownloadCancellation(),
    );
    await server.close(force: true);
    expect(target.readAsBytesSync(), content);
    expect(log, everyElement(endsWith('agent/videoplayback')));
  });

  test('moves to the next source when one is refused and continues where it was', () async {
    final (server, log) = await _serve(content, allowedBytes: 300000);
    final target = File('${dir.path}/out.bin');
    var progress = 0;
    await downloader().download(
      sources: [source(server, '/refuse'), source(server, '/videoplayback')],
      totalBytes: content.length,
      target: target,
      cancellation: DownloadCancellation(),
      onProgress: (bytes) => progress = bytes,
    );
    await server.close(force: true);
    expect(target.readAsBytesSync(), content);
    expect(progress, content.length);
    expect(log.where((l) => l.startsWith('/videoplayback')), isNotEmpty);
  });

  test('splits requests to the chunk size of the source it switched to', () async {
    final (server, _) = await _serve(content, allowedBytes: 0, maxRange: 50000);
    final target = File('${dir.path}/out.bin');
    await downloader().download(
      sources: [source(server, '/refuse'), source(server, '/small', header: true, chunk: 50000)],
      totalBytes: content.length,
      target: target,
      cancellation: DownloadCancellation(),
    );
    await server.close(force: true);
    expect(target.readAsBytesSync(), content);
  });

  test('falls back to a progressive read when ranged requests are refused', () async {
    final (server, log) = await _serve(content);
    final target = File('${dir.path}/out.bin');
    var progress = 0;
    await downloader().download(
      sources: [source(server, '/progressive-only', header: true)],
      totalBytes: content.length,
      target: target,
      cancellation: DownloadCancellation(),
      onProgress: (bytes) => progress = bytes,
    );
    await server.close(force: true);
    expect(target.readAsBytesSync(), content);
    expect(progress, content.length);
    expect(log.last, contains('0-'));
  });

  test('throws StreamForbiddenException when every source refuses', () async {
    final (server, _) = await _serve(content, allowedBytes: 0);
    await expectLater(
      downloader().download(
        sources: [source(server, '/refuse'), source(server, '/refuse2')],
        totalBytes: content.length,
        target: File('${dir.path}/out.bin'),
        cancellation: DownloadCancellation(),
      ),
      throwsA(isA<StreamForbiddenException>()),
    );
    await server.close(force: true);
  });

  test('stops with DownloadCancelledException when cancelled', () async {
    final (server, _) = await _serve(content);
    final cancellation = DownloadCancellation();
    final future = downloader().download(
      sources: [source(server, '/videoplayback')],
      totalBytes: content.length,
      target: File('${dir.path}/out.bin'),
      cancellation: cancellation,
      onProgress: (bytes) {
        if (bytes > 200000) cancellation.cancel();
      },
    );
    await expectLater(future, throwsA(isA<DownloadCancelledException>()));
    await server.close(force: true);
  });
}
