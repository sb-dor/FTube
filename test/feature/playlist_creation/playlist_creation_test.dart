import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/database/database.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/playlist_creation/controller/playlist_creation_controller.dart';
import 'package:youtube/src/feature/playlist_creation/data/playlist_creation_repository.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/controllers/playlist_creation_data_controller.dart';

class _MockPlaylistCreationRepository extends Mock implements IPlaylistCreationRepository {}

bool _settled(PlaylistCreationState state) =>
    state is PlaylistCreation$CompletedState || state is PlaylistCreation$ErrorState;

void main() {
  group('PlaylistCreationRepositoryImpl', () {
    test('inserts a playlist and returns its id', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final repository = PlaylistCreationRepositoryImpl(database: db);

      final first = await repository.create('Music');
      final second = await repository.create('News');

      expect(second, greaterThan(first));
      final rows = await db.select(db.playlists).get();
      expect(rows.map((row) => (row.id, row.name)), [(first, 'Music'), (second, 'News')]);
    });
  });

  group('PlaylistCreationController', () {
    late _MockPlaylistCreationRepository repository;
    late PlaylistCreationController controller;

    setUp(() {
      repository = _MockPlaylistCreationRepository();
      controller = PlaylistCreationController(playlistCreationRepository: repository);
    });
    tearDown(() => controller.dispose());

    test('creates a playlist with the trimmed name', () async {
      when(() => repository.create('Music')).thenAnswer((_) async => 7);
      controller.create('  Music ');
      await controller.waitFor(_settled);
      expect(controller.state, const PlaylistCreationState.completed(playlistId: 7));
    });

    test('ignores a blank name', () async {
      controller.create('   ');
      await Future<void>.delayed(Duration.zero);
      expect(controller.state, const PlaylistCreationState.initial());
      verifyZeroInteractions(repository);
    });

    test('a failure moves to error', () async {
      when(() => repository.create(any())).thenThrow(StateError('db'));
      controller.create('Music');
      await controller.waitFor(_settled);
      expect(controller.state, isA<PlaylistCreation$ErrorState>());
    });
  });

  group('PlaylistCreationDataController', () {
    test('shows the empty-name error only after a submit attempt', () {
      final data = PlaylistCreationDataController();
      addTearDown(data.dispose);

      expect(data.showEmptyError, isFalse);
      expect(data.submit(), isFalse);
      expect(data.showEmptyError, isTrue);

      data.setName(' Mix ');
      expect(data.showEmptyError, isFalse);
      expect(data.submit(), isTrue);
    });
  });
}
