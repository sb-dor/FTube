import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/media_stream.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';
import 'package:youtube/src/feature/video_download/models/download_request.dart';

class _MockRepository extends Mock implements IVideoDownloadRepository {}

void main() {
  late _MockRepository repository;
  late VideoDownloadController controller;
  final request = DownloadRequest(
    video: const VideoItem(id: 'abcdefghijk', title: 'Song'),
    option: DownloadOption.audio(
      audio: MediaStream(
        itag: 140,
        kind: MediaStreamKind.audio,
        container: 'mp4',
        sizeBytes: 100,
        bitrate: 128000,
        sources: [StreamSource(url: Uri.parse('https://example.com'), client: 'TEST')],
      ),
    ),
    target: DownloadTarget.appStorage,
  );

  setUpAll(() => registerFallbackValue(request));

  setUp(() {
    repository = _MockRepository();
    controller = VideoDownloadController(repository: repository);
  });

  tearDown(() => controller.dispose());

  test('reports progress and completes', () async {
    final progress = StreamController<DownloadProgress>();
    when(() => repository.download(any())).thenAnswer((_) => progress.stream);

    expect(controller.start(request), isTrue);
    await pumpEventQueue();
    progress.add(
      const DownloadProgress(phase: DownloadPhase.downloading, receivedBytes: 50, totalBytes: 100),
    );
    await pumpEventQueue();
    final state = controller.state;
    expect(state, isA<VideoDownload$InProgressState>());
    expect((state as VideoDownload$InProgressState).progress.fraction, 0.5);

    await progress.close();
    await pumpEventQueue();
    expect(controller.state, isA<VideoDownload$CompletedState>());
    expect(controller.state.activeRequest, request);
  });

  test('refuses a second download while one is running', () async {
    when(() => repository.download(any()))
        .thenAnswer((_) => StreamController<DownloadProgress>().stream);
    expect(controller.start(request), isTrue);
    await pumpEventQueue();
    expect(controller.start(request), isFalse);
    verify(() => repository.download(any())).called(1);
  });

  test('moves to the error state when the download fails', () async {
    when(() => repository.download(any()))
        .thenAnswer((_) => Stream<DownloadProgress>.error(Exception('network')));
    controller.start(request);
    await pumpEventQueue();
    expect(controller.state, isA<VideoDownload$ErrorState>());
    controller.reset();
    expect(controller.state, isA<VideoDownload$IdleState>());
  });

  test('cancel stops the stream and returns to idle; a new download can start', () async {
    var cancelled = false;
    final progress = StreamController<DownloadProgress>(onCancel: () => cancelled = true);
    addTearDown(progress.close);
    when(() => repository.download(any())).thenAnswer((_) => progress.stream);
    controller.start(request);
    await pumpEventQueue();

    controller.cancel();
    await pumpEventQueue();
    expect(cancelled, isTrue);
    expect(controller.state, isA<VideoDownload$IdleState>());

    when(() => repository.download(any())).thenAnswer((_) => const Stream.empty());
    expect(controller.start(request), isTrue);
    await pumpEventQueue();
    expect(controller.state, isA<VideoDownload$CompletedState>());
  });
}
