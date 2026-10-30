import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/video/controller/video_bookmark_controller.dart';
import 'package:youtube/src/feature/video/controller/video_like_controller.dart';
import 'package:youtube/src/feature/video/controller/video_like_toggle_controller.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';

class _MockVideoLibraryRepository extends Mock implements IVideoLibraryRepository {}

const _video = VideoItem(id: 'abcdefghijk', title: 'Song');

void main() {
  late _MockVideoLibraryRepository repository;

  setUpAll(() => registerFallbackValue(_video));

  setUp(() => repository = _MockVideoLibraryRepository());

  group('VideoLikeController', () {
    late StreamController<bool> liked;
    late VideoLikeController controller;

    setUp(() {
      liked = StreamController<bool>();
      when(() => repository.watchLiked(any())).thenAnswer((_) => liked.stream);
      controller = VideoLikeController(videoLibraryRepository: repository);
    });

    tearDown(() {
      controller.dispose();
      unawaited(liked.close());
    });

    test('follows the liked state', () async {
      expect(controller.state.isLiked, isFalse);
      controller.watch(_video.id);
      await pumpEventQueue();
      expect(controller.state, isA<VideoLike$InProgressState>());

      liked.add(true);
      await pumpEventQueue();
      expect(controller.state, const VideoLikeState.completed(liked: true));
      expect(controller.state.isLiked, isTrue);

      liked.add(false);
      await pumpEventQueue();
      expect(controller.state, const VideoLikeState.completed(liked: false));
      verify(() => repository.watchLiked(_video.id)).called(1);
    });

    test('a failing watch sets the error state', () async {
      controller.watch(_video.id);
      await pumpEventQueue();
      liked.addError(Exception('database'));
      await pumpEventQueue();
      expect(controller.state, isA<VideoLike$ErrorState>());
    });

    test('watching again cancels the previous subscription', () async {
      var cancelled = false;
      final first = StreamController<bool>(onCancel: () => cancelled = true);
      addTearDown(first.close);
      when(() => repository.watchLiked('first')).thenAnswer((_) => first.stream);
      controller
        ..watch('first')
        ..watch(_video.id);
      await pumpEventQueue();
      expect(cancelled, isTrue);
      liked.add(true);
      await pumpEventQueue();
      expect(controller.state.isLiked, isTrue);
    });
  });

  group('VideoLikeToggleController', () {
    late VideoLikeToggleController controller;

    setUp(() => controller = VideoLikeToggleController(videoLibraryRepository: repository));

    tearDown(() => controller.dispose());

    test('saves the like and completes', () async {
      when(() => repository.setLiked(any(), liked: any(named: 'liked'))).thenAnswer((_) async {});
      controller.setLiked(_video, liked: true);
      await pumpEventQueue();
      expect(controller.state, const VideoLikeToggleState.completed(liked: true));
      verify(() => repository.setLiked(_video, liked: true)).called(1);
    });

    test('drops taps while saving', () async {
      final saving = Completer<void>();
      when(() => repository.setLiked(any(), liked: any(named: 'liked')))
          .thenAnswer((_) => saving.future);
      controller
        ..setLiked(_video, liked: true)
        ..setLiked(_video, liked: false);
      await pumpEventQueue();
      expect(controller.state, isA<VideoLikeToggle$InProgressState>());
      saving.complete();
      await pumpEventQueue();
      expect(controller.state, const VideoLikeToggleState.completed(liked: true));
      verify(() => repository.setLiked(any(), liked: any(named: 'liked'))).called(1);
    });

    test('a failed save sets the error state', () async {
      when(() => repository.setLiked(any(), liked: any(named: 'liked')))
          .thenThrow(Exception('database'));
      controller.setLiked(_video, liked: true);
      await pumpEventQueue();
      expect(controller.state, isA<VideoLikeToggle$ErrorState>());
    });
  });

  group('VideoBookmarkController', () {
    late StreamController<bool> saved;
    late VideoBookmarkController controller;

    setUp(() {
      saved = StreamController<bool>();
      when(() => repository.watchInPlaylist(any())).thenAnswer((_) => saved.stream);
      controller = VideoBookmarkController(videoLibraryRepository: repository);
    });

    tearDown(() {
      controller.dispose();
      unawaited(saved.close());
    });

    test('follows whether the video is in a playlist', () async {
      expect(controller.state.isSaved, isFalse);
      controller.watch(_video.id);
      await pumpEventQueue();
      saved.add(true);
      await pumpEventQueue();
      expect(controller.state, const VideoBookmarkState.completed(saved: true));
      expect(controller.state.isSaved, isTrue);
    });

    test('a failing watch sets the error state', () async {
      controller.watch(_video.id);
      await pumpEventQueue();
      saved.addError(Exception('database'));
      await pumpEventQueue();
      expect(controller.state, isA<VideoBookmark$ErrorState>());
      expect(controller.state.isSaved, isFalse);
    });
  });
}
