import 'package:flutter/material.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/playlist_video_removal/controller/playlist_video_removal_controller.dart';
import 'package:youtube/src/feature/playlist_video_removal/data/playlist_video_removal_repository.dart';
import 'package:youtube/src/feature/playlist_video_removal/widgets/playlist_video_removal_dialog_widget.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

/// Provides [PlaylistVideoRemovalConfigWidgetState] to the removal dialog.
class PlaylistVideoRemovalConfigInhWidget extends InheritedWidget {
  const PlaylistVideoRemovalConfigInhWidget({required this.state, required super.child, super.key});

  final PlaylistVideoRemovalConfigWidgetState state;

  static PlaylistVideoRemovalConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<PlaylistVideoRemovalConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'PlaylistVideoRemovalConfigInhWidget was not found in the widget tree');
    return (widget! as PlaylistVideoRemovalConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant PlaylistVideoRemovalConfigInhWidget oldWidget) => false;
}

/// Confirms and removes a video from a playlist (or from the liked videos).
class PlaylistVideoRemovalConfigWidget extends StatefulWidget {
  const PlaylistVideoRemovalConfigWidget({
    required this.playlist,
    required this.video,
    required this.builder,
    super.key,
    this.onSuccessfullyDelete,
  });

  /// Shows the confirmation dialog; completes when it closes.
  static Future<void> show(
    BuildContext context, {
    required PlaylistSummary playlist,
    required VideoItem video,
    VoidCallback? onSuccessfullyDelete,
  }) => showDialog<void>(
    context: context,
    builder: (context) => PlaylistVideoRemovalConfigWidget(
      playlist: playlist,
      video: video,
      onSuccessfullyDelete: onSuccessfullyDelete,
      builder: (context) => const PlaylistVideoRemovalDialogWidget(),
    ),
  );

  final PlaylistSummary playlist;
  final VideoItem video;
  final WidgetBuilder builder;
  final VoidCallback? onSuccessfullyDelete;

  @override
  State<PlaylistVideoRemovalConfigWidget> createState() => PlaylistVideoRemovalConfigWidgetState();
}

class PlaylistVideoRemovalConfigWidgetState extends State<PlaylistVideoRemovalConfigWidget> {
  late final PlaylistVideoRemovalController playlistVideoRemovalController;
  late final PlaylistSummary playlist = widget.playlist;
  late final VideoItem video = widget.video;
  late final VoidCallback? onSuccessfullyDelete = widget.onSuccessfullyDelete;

  @override
  void initState() {
    super.initState();
    playlistVideoRemovalController = PlaylistVideoRemovalController(
      playlistVideoRemovalRepository: PlaylistVideoRemovalRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
  }

  @override
  void dispose() {
    playlistVideoRemovalController.dispose();
    super.dispose();
  }

  void remove() => playlistVideoRemovalController.remove(playlist: playlist, videoId: video.id);

  @override
  Widget build(BuildContext context) =>
      PlaylistVideoRemovalConfigInhWidget(state: this, child: widget.builder(context));
}
