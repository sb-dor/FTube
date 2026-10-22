import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/playlist_video_removal/controller/playlist_video_removal_controller.dart';
import 'package:youtube/src/feature/playlist_video_removal/data/playlist_video_removal_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

class _MockPlaylistVideoRemovalRepository extends Mock implements IPlaylistVideoRemovalRepository {}

bool _settled(PlaylistVideoRemovalState state) =>
    state is PlaylistVideoRemoval$CompletedState || state is PlaylistVideoRemoval$ErrorState;

VideoItem _video(String id) => VideoItem(id: id, title: id);

void main() {
  group('PlaylistVideoRemovalRepositoryImpl', () {
    late AppDatabase db;
    late PlaylistVideoRemovalRepositoryImpl repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = PlaylistVideoRemovalRepositoryImpl(database: db);
    });
    tearDown(() => db.close());

    test('removes the video from that playlist only', () async {
      final music = await db
          .into(db.playlists)
          .insert(PlaylistsCompanion.insert(name: const Value('Music')));
      final news = await db
          .into(db.playlists)
          .insert(PlaylistsCompanion.insert(name: const Value('News')));
      await db.into(db.playlistVideos).insert(_video('a').toPlaylistVideoCompanion(music));
      await db.into(db.playlistVideos).insert(_video('b').toPlaylistVideoCompanion(music));
      await db.into(db.playlistVideos).insert(_video('a').toPlaylistVideoCompanion(news));

      await repository.removeFromPlaylist(playlistId: music, videoId: 'a');

      final rows = await db.select(db.playlistVideos).get();
      expect(rows.map((row) => (row.playlistId, row.videoId)), [(music, 'b'), (news, 'a')]);
    });

    test('unlike removes the like', () async {
      await db.into(db.likes).insert(_video('a').toLikeCompanion());
      await db.into(db.likes).insert(_video('b').toLikeCompanion());

      await repository.unlike('a');

      expect((await db.select(db.likes).get()).map((row) => row.videoId), ['b']);
    });
  });

  group('PlaylistVideoRemovalController', () {
    late _MockPlaylistVideoRemovalRepository repository;
    late PlaylistVideoRemovalController controller;

    setUp(() {
      repository = _MockPlaylistVideoRemovalRepository();
      when(
        () => repository.removeFromPlaylist(
          playlistId: any(named: 'playlistId'),
          videoId: any(named: 'videoId'),
        ),
      ).thenAnswer((_) async {});
      when(() => repository.unlike(any())).thenAnswer((_) async {});
      controller = PlaylistVideoRemovalController(playlistVideoRemovalRepository: repository);
    });
    tearDown(() => controller.dispose());

    test('removes from a user playlist', () async {
      controller.remove(
        playlist: const UserPlaylistSummary(id: 4, name: 'Music', videoCount: 1),
        videoId: 'a',
      );
      await controller.waitFor(_settled);
      expect(controller.state, const PlaylistVideoRemovalState.completed());
      verify(() => repository.removeFromPlaylist(playlistId: 4, videoId: 'a')).called(1);
      verifyNever(() => repository.unlike(any()));
    });

    test('unlikes from the liked videos', () async {
      controller.remove(playlist: const LikedPlaylistSummary(videoCount: 1), videoId: 'a');
      await controller.waitFor(_settled);
      verify(() => repository.unlike('a')).called(1);
    });

    test('a failure moves to error', () async {
      when(() => repository.unlike(any())).thenThrow(StateError('db'));
      controller.remove(playlist: const LikedPlaylistSummary(videoCount: 1), videoId: 'a');
      await controller.waitFor(_settled);
      expect(controller.state, isA<PlaylistVideoRemoval$ErrorState>());
    });
  });
}
