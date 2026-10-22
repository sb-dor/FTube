import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/playlists/controller/playlists_controller.dart';
import 'package:youtube/src/feature/playlists/data/playlists_repository.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

class _MockPlaylistsRepository extends Mock implements IPlaylistsRepository {}

void main() {
  late _MockPlaylistsRepository repository;
  late StreamController<List<PlaylistSummary>> source;
  late PlaylistsController controller;

  setUp(() {
    repository = _MockPlaylistsRepository();
    source = StreamController<List<PlaylistSummary>>();
    when(() => repository.watchPlaylists()).thenAnswer((_) => source.stream);
    controller = PlaylistsController(playlistsRepository: repository);
  });

  tearDown(() {
    controller.dispose();
    source.close();
  });

  test('emits every value of the watched playlists', () async {
    controller.watch();
    await controller.waitFor((state) => state is Playlists$InProgressState);

    const first = [LikedPlaylistSummary(videoCount: 1)];
    source.add(first);
    await controller.waitFor((state) => state is Playlists$CompletedState);
    expect(controller.state, const PlaylistsState.completed(playlists: first));

    const second = [UserPlaylistSummary(id: 1, name: 'Music', videoCount: 0)];
    source.add(second);
    await controller.waitFor(
      (state) => state is Playlists$CompletedState && state.playlists.first == second.first,
    );
    expect(controller.state, const PlaylistsState.completed(playlists: second));
  });

  test('moves to error when the stream fails', () async {
    controller.watch();
    source.addError(StateError('db'));
    await controller.waitFor((state) => state is Playlists$ErrorState);
  });
}
