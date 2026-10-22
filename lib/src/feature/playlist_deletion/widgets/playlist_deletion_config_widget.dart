import 'package:flutter/material.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/playlist_deletion/controller/playlist_deletion_controller.dart';
import 'package:youtube/src/feature/playlist_deletion/data/playlist_deletion_repository.dart';
import 'package:youtube/src/feature/playlist_deletion/widgets/playlist_deletion_dialog_widget.dart';

/// Provides [PlaylistDeletionConfigWidgetState] to the delete-playlist dialog.
class PlaylistDeletionConfigInhWidget extends InheritedWidget {
  const PlaylistDeletionConfigInhWidget({required this.state, required super.child, super.key});

  final PlaylistDeletionConfigWidgetState state;

  static PlaylistDeletionConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<PlaylistDeletionConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'PlaylistDeletionConfigInhWidget was not found in the widget tree');
    return (widget! as PlaylistDeletionConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant PlaylistDeletionConfigInhWidget oldWidget) => false;
}

/// Confirms and deletes a playlist with its videos.
class PlaylistDeletionConfigWidget extends StatefulWidget {
  const PlaylistDeletionConfigWidget({
    required this.playlistId,
    required this.name,
    required this.builder,
    super.key,
    this.onSuccessfullyDelete,
  });

  /// Shows the confirmation dialog; completes when it closes.
  static Future<void> show(
    BuildContext context, {
    required int playlistId,
    required String name,
    VoidCallback? onSuccessfullyDelete,
  }) => showDialog<void>(
    context: context,
    builder: (context) => PlaylistDeletionConfigWidget(
      playlistId: playlistId,
      name: name,
      onSuccessfullyDelete: onSuccessfullyDelete,
      builder: (context) => const PlaylistDeletionDialogWidget(),
    ),
  );

  final int playlistId;
  final String name;
  final WidgetBuilder builder;
  final VoidCallback? onSuccessfullyDelete;

  @override
  State<PlaylistDeletionConfigWidget> createState() => PlaylistDeletionConfigWidgetState();
}

class PlaylistDeletionConfigWidgetState extends State<PlaylistDeletionConfigWidget> {
  late final PlaylistDeletionController playlistDeletionController;
  late final int playlistId = widget.playlistId;
  late final String name = widget.name;
  late final VoidCallback? onSuccessfullyDelete = widget.onSuccessfullyDelete;

  @override
  void initState() {
    super.initState();
    playlistDeletionController = PlaylistDeletionController(
      playlistDeletionRepository: PlaylistDeletionRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
  }

  @override
  void dispose() {
    playlistDeletionController.dispose();
    super.dispose();
  }

  void delete() => playlistDeletionController.delete(playlistId);

  @override
  Widget build(BuildContext context) =>
      PlaylistDeletionConfigInhWidget(state: this, child: widget.builder(context));
}
