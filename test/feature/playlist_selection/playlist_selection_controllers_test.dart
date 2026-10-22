import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/playlist_selection/controller/playlist_selection_controller.dart';
import 'package:youtube/src/feature/playlist_selection/controller/playlist_selection_save_controller.dart';
import 'package:youtube/src/feature/playlist_selection/data/playlist_selection_repository.dart';
import 'package:youtube/src/feature/playlist_selection/models/playlist_option.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/controllers/playlist_selection_data_controller.dart';

class _MockPlaylistSelectionRepository extends Mock implements IPlaylistSelectionRepository {}

const _video = VideoItem(id: 'v', title: 'Video');

void main() {
  late _MockPlaylistSelectionRepository repository;

  setUpAll(() => registerFallbackValue(_video));
  setUp(() => repository = _MockPlaylistSelectionRepository());

  group('PlaylistSelectionController', () {
    late StreamController<List<PlaylistOption>> source;
    late PlaylistSelectionController controller;

    setUp(() {
      source = StreamController<List<PlaylistOption>>();
      when(() => repository.watchPlaylists()).thenAnswer((_) => source.stream);
      controller = PlaylistSelectionController(playlistSelectionRepository: repository);
    });

    tearDown(() {
      controller.dispose();
      source.close();
    });

    test('loads the playlists and the one holding the video', () async {
      when(() => repository.playlistOf('v')).thenAnswer((_) async => 2);
      controller.load(videoId: 'v');
      source.add(const [PlaylistOption(id: 2, name: 'Music')]);

      await controller.waitFor((state) => state is PlaylistSelection$CompletedState);
      final state = controller.state as PlaylistSelection$CompletedState;
      expect(state.playlists, const [PlaylistOption(id: 2, name: 'Music')]);
      expect(state.currentPlaylistId, 2);

      source.add(const [PlaylistOption(id: 3, name: 'New'), PlaylistOption(id: 2, name: 'Music')]);
      await controller.waitFor(
        (state) => state is PlaylistSelection$CompletedState && state.playlists.length == 2,
      );
      expect((controller.state as PlaylistSelection$CompletedState).currentPlaylistId, 2);
    });

    test('a failure moves to error', () async {
      when(() => repository.playlistOf(any())).thenThrow(StateError('db'));
      controller.load(videoId: 'v');
      await controller.waitFor((state) => state is PlaylistSelection$ErrorState);
    });
  });

  group('PlaylistSelectionSaveController', () {
    late PlaylistSelectionSaveController controller;

    setUp(
      () => controller = PlaylistSelectionSaveController(playlistSelectionRepository: repository),
    );
    tearDown(() => controller.dispose());

    bool settled(PlaylistSelectionSaveState state) =>
        state is PlaylistSelectionSave$CompletedState || state is PlaylistSelectionSave$ErrorState;

    test('moves the video into the playlist', () async {
      when(() => repository.assign(_video, playlistId: 5)).thenAnswer((_) async {});
      controller.save(_video, playlistId: 5);
      await controller.waitFor(settled);
      expect(controller.state, const PlaylistSelectionSaveState.completed(playlistId: 5));
    });

    test('removes the video from playlists when nothing is chosen', () async {
      when(() => repository.assign(_video, playlistId: null)).thenAnswer((_) async {});
      controller.save(_video, playlistId: null);
      await controller.waitFor(settled);
      expect(controller.state, const PlaylistSelectionSaveState.completed(playlistId: null));
    });

    test('a failure moves to error', () async {
      when(() => repository.assign(any(), playlistId: any(named: 'playlistId')))
          .thenThrow(StateError('db'));
      controller.save(_video, playlistId: 5);
      await controller.waitFor(settled);
      expect(controller.state, isA<PlaylistSelectionSave$ErrorState>());
    });
  });

  group('PlaylistSelectionDataController', () {
    test('pre-selects once, then toggles a single choice', () {
      final data = PlaylistSelectionDataController();
      addTearDown(data.dispose);

      data.initialize(2);
      expect(data.selectedId, 2);
      data.initialize(9);
      expect(data.selectedId, 2);

      data.toggle(3);
      expect(data.selectedId, 3);
      data.toggle(3);
      expect(data.selectedId, isNull);

      data.select(4);
      expect(data.selectedId, 4);
    });

    test('a pick made before the playlists load wins over the pre-selection', () {
      final data = PlaylistSelectionDataController()..select(7);
      addTearDown(data.dispose);

      data.initialize(2);
      expect(data.selectedId, 7);
    });
  });
}
