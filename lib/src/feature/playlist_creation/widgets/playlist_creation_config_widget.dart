import 'package:flutter/material.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/playlist_creation/controller/playlist_creation_controller.dart';
import 'package:youtube/src/feature/playlist_creation/data/playlist_creation_repository.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/controllers/playlist_creation_data_controller.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/playlist_creation_dialog_widget.dart';

/// Provides [PlaylistCreationConfigWidgetState] to the create-playlist dialog.
class PlaylistCreationConfigInhWidget extends InheritedWidget {
  const PlaylistCreationConfigInhWidget({required this.state, required super.child, super.key});

  final PlaylistCreationConfigWidgetState state;

  static PlaylistCreationConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<PlaylistCreationConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'PlaylistCreationConfigInhWidget was not found in the widget tree');
    return (widget! as PlaylistCreationConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant PlaylistCreationConfigInhWidget oldWidget) => false;
}

/// "New playlist" dialog.
class PlaylistCreationConfigWidget extends StatefulWidget {
  const PlaylistCreationConfigWidget({required this.builder, super.key, this.onCreated});

  /// Shows the dialog; [onCreated] receives the new playlist's id before it closes.
  /// Completes when the dialog closes.
  static Future<void> show(BuildContext context, {ValueChanged<int>? onCreated}) =>
      showDialog<void>(
        context: context,
        builder: (context) => PlaylistCreationConfigWidget(
          onCreated: onCreated,
          builder: (context) => const PlaylistCreationDialogWidget(),
        ),
      );

  final WidgetBuilder builder;
  final ValueChanged<int>? onCreated;

  @override
  State<PlaylistCreationConfigWidget> createState() => PlaylistCreationConfigWidgetState();
}

class PlaylistCreationConfigWidgetState extends State<PlaylistCreationConfigWidget> {
  late final PlaylistCreationController playlistCreationController;
  late final PlaylistCreationDataController playlistCreationDataController;
  late final ValueChanged<int>? onCreated = widget.onCreated;

  @override
  void initState() {
    super.initState();
    playlistCreationController = PlaylistCreationController(
      playlistCreationRepository: PlaylistCreationRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
    playlistCreationDataController = PlaylistCreationDataController();
  }

  @override
  void dispose() {
    playlistCreationController.dispose();
    playlistCreationDataController.dispose();
    super.dispose();
  }

  /// Validates the name and creates the playlist.
  void save() {
    if (!playlistCreationDataController.submit()) return;
    playlistCreationController.create(playlistCreationDataController.name);
  }

  @override
  Widget build(BuildContext context) =>
      PlaylistCreationConfigInhWidget(state: this, child: widget.builder(context));
}
