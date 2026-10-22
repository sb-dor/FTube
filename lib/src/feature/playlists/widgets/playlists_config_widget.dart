import 'package:flutter/material.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/playlists/controller/playlists_controller.dart';
import 'package:youtube/src/feature/playlists/data/playlists_repository.dart';
import 'package:youtube/src/feature/playlists/widgets/mobile/playlists_mobile_widget.dart';

/// Provides [PlaylistsConfigWidgetState] to the playlists screen.
class PlaylistsConfigInhWidget extends InheritedWidget {
  const PlaylistsConfigInhWidget({required this.state, required super.child, super.key});

  final PlaylistsConfigWidgetState state;

  static PlaylistsConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<PlaylistsConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'PlaylistsConfigInhWidget was not found in the widget tree');
    return (widget! as PlaylistsConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant PlaylistsConfigInhWidget oldWidget) => false;
}

/// "Playlists" screen: a grid of all playlists, including "Liked videos".
class PlaylistsConfigWidget extends StatefulWidget {
  const PlaylistsConfigWidget({super.key});

  static Future<void> open(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(builder: (context) => const PlaylistsConfigWidget()),
  );

  @override
  State<PlaylistsConfigWidget> createState() => PlaylistsConfigWidgetState();
}

class PlaylistsConfigWidgetState extends State<PlaylistsConfigWidget> {
  late final PlaylistsController playlistsController;

  @override
  void initState() {
    super.initState();
    playlistsController = PlaylistsController(
      playlistsRepository: PlaylistsRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
    watch();
  }

  @override
  void dispose() {
    playlistsController.dispose();
    super.dispose();
  }

  void watch() => playlistsController.watch();

  @override
  Widget build(BuildContext context) =>
      PlaylistsConfigInhWidget(state: this, child: const PlaylistsMobileWidget());
}
