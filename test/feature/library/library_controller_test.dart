import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/feature/library/controller/library_controller.dart';
import 'package:youtube/src/feature/library/data/library_repository.dart';
import 'package:youtube/src/feature/library/models/library_overview.dart';

class _MockLibraryRepository extends Mock implements ILibraryRepository {}

void main() {
  late _MockLibraryRepository repository;
  late StreamController<LibraryOverview> source;
  late LibraryController controller;

  setUp(() {
    repository = _MockLibraryRepository();
    source = StreamController<LibraryOverview>();
    when(() => repository.watchOverview()).thenAnswer((_) => source.stream);
    controller = LibraryController(libraryRepository: repository);
  });

  tearDown(() {
    controller.dispose();
    source.close();
  });

  test('follows the watched overview', () async {
    controller.watch();
    const empty = LibraryOverview(history: [], playlists: [], downloadsCount: 0);
    source.add(empty);
    await controller.waitFor((state) => state is Library$CompletedState);
    expect(controller.state, const LibraryState.completed(overview: empty));

    const updated = LibraryOverview(
      history: [VideoItem(id: 'a', title: 'a')],
      playlists: [],
      downloadsCount: 2,
    );
    source.add(updated);
    await controller.waitFor(
      (state) => state is Library$CompletedState && state.overview == updated,
    );
  });

  test('a failing stream moves to error, and watch recovers', () async {
    controller.watch();
    source.addError(StateError('db'));
    await controller.waitFor((state) => state is Library$ErrorState);

    final retry = StreamController<LibraryOverview>();
    addTearDown(retry.close);
    when(() => repository.watchOverview()).thenAnswer((_) => retry.stream);
    controller.watch();
    retry.add(const LibraryOverview(history: [], playlists: [], downloadsCount: 0));
    await controller.waitFor((state) => state is Library$CompletedState);
  });
}
