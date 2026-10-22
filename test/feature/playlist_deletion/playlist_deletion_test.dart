import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/database/video_row_mapping.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/playlist_deletion/controller/playlist_deletion_controller.dart';
import 'package:youtube/src/feature/playlist_deletion/data/playlist_deletion_repository.dart';

class _MockPlaylistDeletionRepository extends Mock implements IPlaylistDeletionRepository {}

bool _settled(PlaylistDeletionState state) =>
    state is PlaylistDeletion$CompletedState || state is PlaylistDeletion$ErrorState;

void main() {
  group('PlaylistDeletionRepositoryImpl', () {
    test('deletes the playlist and its videos only', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      Future<int> playlist(String name) =>
          db.into(db.playlists).insert(PlaylistsCompanion.insert(name: Value(name)));
      final music = await playlist('Music');
      final news = await playlist('News');
      for (final (id, playlistId) in [('a', music), ('b', music), ('c', news)]) {
        await db
            .into(db.playlistVideos)
            .insert(VideoItem(id: id, title: id).toPlaylistVideoCompanion(playlistId));
      }

      await PlaylistDeletionRepositoryImpl(database: db).delete(music);

      expect((await db.select(db.playlists).get()).map((row) => row.name), ['News']);
      expect((await db.select(db.playlistVideos).get()).map((row) => row.videoId), ['c']);
    });
  });

  group('PlaylistDeletionController', () {
    late _MockPlaylistDeletionRepository repository;
    late PlaylistDeletionController controller;

    setUp(() {
      repository = _MockPlaylistDeletionRepository();
      controller = PlaylistDeletionController(playlistDeletionRepository: repository);
    });
    tearDown(() => controller.dispose());

    test('deletes the playlist', () async {
      when(() => repository.delete(3)).thenAnswer((_) async {});
      controller.delete(3);
      await controller.waitFor(_settled);
      expect(controller.state, const PlaylistDeletionState.completed());
      verify(() => repository.delete(3)).called(1);
    });

    test('a failure moves to error', () async {
      when(() => repository.delete(any())).thenThrow(StateError('db'));
      controller.delete(3);
      await controller.waitFor(_settled);
      expect(controller.state, isA<PlaylistDeletion$ErrorState>());
    });
  });
}
