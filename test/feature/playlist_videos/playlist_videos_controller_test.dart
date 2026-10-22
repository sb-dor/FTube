import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/playlist_videos/controller/playlist_videos_controller.dart';
import 'package:youtube/src/feature/playlist_videos/data/playlist_videos_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

class _MockPlaylistVideosRepository extends Mock implements IPlaylistVideosRepository {}

const _liked = LikedPlaylistSummary(videoCount: 3);

List<VideoItem> _videos(int count) => [
  for (var i = 0; i < count; i++) VideoItem(id: '$i', title: '$i'),
];

void main() {
  late _MockPlaylistVideosRepository repository;
  late Map<int, StreamController<PlaylistVideosPage>> sources;
  late PlaylistVideosController controller;

  setUpAll(() => registerFallbackValue(_liked));

  setUp(() {
    repository = _MockPlaylistVideosRepository();
    sources = {};
    when(
      () => repository.watchVideos(
        playlist: any(named: 'playlist'),
        limit: any(named: 'limit'),
      ),
    ).thenAnswer((invocation) {
      final limit = invocation.namedArguments[#limit] as int;
      return (sources[limit] = StreamController<PlaylistVideosPage>()).stream;
    });
    controller = PlaylistVideosController(playlistVideosRepository: repository, pageSize: 2);
  });

  tearDown(() {
    controller.dispose();
    for (final source in sources.values) {
      source.close();
    }
  });

  Future<void> emit(int limit, PlaylistVideosPage page) async {
    while (sources[limit] == null) {
      await Future<void>.delayed(Duration.zero);
    }
    sources[limit]!.add(page);
  }

  test('load then paginate widen the watched window for the same playlist', () async {
    controller.load(playlist: _liked);
    await emit(2, (videos: _videos(2), hasMore: true));
    await controller.waitFor((state) => state is PlaylistVideos$CompletedState);

    controller.paginate(playlist: _liked);
    await emit(4, (videos: _videos(3), hasMore: false));
    await controller.waitFor((state) => state is PlaylistVideos$CompletedState && state.limit == 4);

    expect((controller.state as PlaylistVideos$CompletedState).videos, _videos(3));
    expect(controller.state.canLoadMore, isFalse);
    verify(() => repository.watchVideos(playlist: _liked, limit: 4)).called(1);
  });

  test('a failing stream moves to error', () async {
    controller.load(playlist: _liked);
    while (sources[2] == null) {
      await Future<void>.delayed(Duration.zero);
    }
    sources[2]!.addError(StateError('db'));
    await controller.waitFor((state) => state is PlaylistVideos$ErrorState);
  });
}
