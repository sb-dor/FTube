import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' as p;
import 'package:youtube/src/common/download/device_media_store.dart';
import 'package:youtube/src/feature/download_export/controller/download_export_controller.dart';
import 'package:youtube/src/feature/download_export/data/download_export_repository.dart';
import 'package:youtube/src/feature/download_export/models/download_export_destination.dart';
import 'package:youtube/src/feature/download_export/models/download_export_failure.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';

class _MockDownloadExportRepository extends Mock implements IDownloadExportRepository {}

/// Records saved files; throws [error] when it is set.
class _FakeMediaStore implements IDeviceMediaStore {
  final gallery = <String>[];
  final downloads = <(String, String)>[];
  Exception? error;

  @override
  Future<void> saveVideoToGallery(File file) async {
    if (error case final error?) throw error;
    gallery.add(file.path);
  }

  @override
  Future<void> saveToDownloads(File file, String fileName) async {
    if (error case final error?) throw error;
    downloads.add((file.path, fileName));
  }

  @override
  Future<Directory> appDownloadsDirectory() => throw UnimplementedError();
}

Matcher _fails(DownloadExportFailure failure) =>
    throwsA(isA<DownloadExportException>().having((e) => e.failure, 'failure', failure));

void main() {
  group('DownloadExportRepositoryImpl', () {
    late Directory dir;
    late String video;
    late String audio;
    late _FakeMediaStore mediaStore;

    DownloadExportRepositoryImpl repository() =>
        DownloadExportRepositoryImpl(mediaStore: mediaStore);

    setUp(() {
      dir = Directory.systemTemp.createTempSync('ftube_export_test');
      video = p.join(dir.path, 'video.mp4');
      audio = p.join(dir.path, 'song.m4a');
      File(video).writeAsStringSync('v');
      File(audio).writeAsStringSync('a');
      mediaStore = _FakeMediaStore();
    });

    tearDown(() => dir.deleteSync(recursive: true));

    test('saves a video to the gallery', () async {
      await repository().saveToGallery(video);
      expect(mediaStore.gallery, [video]);
    });

    test('a missing file is reported before touching the media store', () async {
      await expectLater(
        repository().saveToGallery(p.join(dir.path, 'gone.mp4')),
        _fails(DownloadExportFailure.fileMissing),
      );
      await expectLater(
        repository().saveToDownloads(p.join(dir.path, 'gone.m4a'), title: 'x'),
        _fails(DownloadExportFailure.fileMissing),
      );
      expect(mediaStore.gallery, isEmpty);
      expect(mediaStore.downloads, isEmpty);
    });

    test('a denied permission is reported', () async {
      mediaStore.error = const MediaPermissionDeniedException();
      await expectLater(
        repository().saveToGallery(video),
        _fails(DownloadExportFailure.permissionDenied),
      );
      await expectLater(
        repository().saveToDownloads(audio, title: 'Song'),
        _fails(DownloadExportFailure.permissionDenied),
      );
    });

    test('any other error is a generic failure', () async {
      mediaStore.error = const FileSystemException('disk full');
      await expectLater(repository().saveToGallery(video), _fails(DownloadExportFailure.failed));
      await expectLater(
        repository().saveToDownloads(audio, title: 'Song'),
        _fails(DownloadExportFailure.failed),
      );
    });

    test('copies audio into Downloads named after the title', () async {
      await repository().saveToDownloads(audio, title: 'My: song?');
      expect(mediaStore.downloads, [(audio, 'My_ song_.m4a')]);
    });
  });

  group('DownloadExportController', () {
    late _MockDownloadExportRepository repository;
    late DownloadExportController controller;
    const video = DownloadedFile(
      id: 1,
      title: 'Video',
      path: '/files/video.mp4',
      mediaType: DownloadMediaType.video,
      exists: true,
    );
    const audio = DownloadedFile(
      id: 2,
      title: 'Song',
      path: '/files/song.m4a',
      mediaType: DownloadMediaType.audio,
      exists: true,
    );

    setUp(() {
      repository = _MockDownloadExportRepository();
      controller = DownloadExportController(downloadExportRepository: repository);
    });

    tearDown(() => controller.dispose());

    test('saves a video to the gallery', () async {
      when(() => repository.saveToGallery(video.path)).thenAnswer((_) async {});
      final states = <DownloadExportState>[];
      controller.addListener(() => states.add(controller.state));

      controller.export(video);
      expect(controller.state.isSaving(1), isTrue);
      expect(controller.state.isSaving(2), isFalse);
      await pumpEventQueue();

      expect(
        states.last,
        const DownloadExportState.completed(
          fileId: 1,
          destination: DownloadExportDestination.gallery,
        ),
      );
      verifyNever(() => repository.saveToDownloads(any(), title: any(named: 'title')));
    });

    test('saves audio to Downloads', () async {
      when(() => repository.saveToDownloads(audio.path, title: 'Song')).thenAnswer((_) async {});

      controller.export(audio);
      await pumpEventQueue();

      expect(
        controller.state,
        const DownloadExportState.completed(
          fileId: 2,
          destination: DownloadExportDestination.downloads,
        ),
      );
    });

    test('a missing file fails without touching the repository', () async {
      controller.export(video.copyWith(exists: false));
      await pumpEventQueue();

      expect(
        controller.state,
        isA<DownloadExport$ErrorState>()
            .having((s) => s.fileId, 'fileId', 1)
            .having((s) => s.failure, 'failure', DownloadExportFailure.fileMissing),
      );
      verifyZeroInteractions(repository);
    });

    test('reports the repository failure', () async {
      when(() => repository.saveToGallery(video.path))
          .thenThrow(const DownloadExportException(DownloadExportFailure.permissionDenied));

      controller.export(video);
      await pumpEventQueue();

      expect(
        controller.state,
        isA<DownloadExport$ErrorState>().having(
          (s) => s.failure,
          'failure',
          DownloadExportFailure.permissionDenied,
        ),
      );
    });

    test('an unexpected error is a generic failure', () async {
      when(() => repository.saveToGallery(video.path)).thenThrow(StateError('x'));

      controller.export(video);
      await pumpEventQueue();

      expect(
        controller.state,
        isA<DownloadExport$ErrorState>().having(
          (s) => s.failure,
          'failure',
          DownloadExportFailure.failed,
        ),
      );
    });
  });
}
