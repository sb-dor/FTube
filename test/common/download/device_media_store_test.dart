import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gal/gal.dart';
import 'package:youtube/src/common/download/device_media_store.dart';
import 'package:youtube/src/common/utils/public_downloads.dart';

void main() {
  final video = File('/files/video.mp4');
  final audio = File('/files/song.m4a');
  final putVideo = <String>[];
  final copies = <(String, String)>[];
  var galleryAccess = true;

  setUp(() {
    putVideo.clear();
    copies.clear();
    galleryAccess = true;
  });

  DeviceMediaStoreImpl store({
    Future<void> Function(String path)? put,
    Future<void> Function(File file, String fileName)? copy,
  }) => DeviceMediaStoreImpl(
    requestGalleryAccess: () async => galleryAccess,
    putVideo: put ?? (path) async => putVideo.add(path),
    copyIntoDownloads: copy ?? (file, name) async => copies.add((file.path, name)),
  );

  test('saves a video to the gallery', () async {
    await store().saveVideoToGallery(video);
    expect(putVideo, [video.path]);
  });

  test('denied gallery access', () async {
    galleryAccess = false;
    await expectLater(
      store().saveVideoToGallery(video),
      throwsA(isA<MediaPermissionDeniedException>()),
    );
    expect(putVideo, isEmpty);
  });

  test('a gallery access error is a denied permission; other errors pass through', () async {
    await expectLater(
      store(
        put: (_) => throw GalException(
          type: GalExceptionType.accessDenied,
          platformException: PlatformException(code: 'ACCESS_DENIED'),
          stackTrace: StackTrace.empty,
        ),
      ).saveVideoToGallery(video),
      throwsA(isA<MediaPermissionDeniedException>()),
    );
    await expectLater(
      store(put: (_) => throw StateError('boom')).saveVideoToGallery(video),
      throwsA(isA<StateError>()),
    );
  });

  test('copies a file into Downloads', () async {
    await store().saveToDownloads(audio, 'Song.m4a');
    expect(copies, [(audio.path, 'Song.m4a')]);
  });

  test('a denied storage permission is a denied media permission', () async {
    await expectLater(
      store(copy: (_, _) => throw const StoragePermissionDeniedException())
          .saveToDownloads(audio, 'Song.m4a'),
      throwsA(isA<MediaPermissionDeniedException>()),
    );
  });
}
