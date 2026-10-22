import 'package:flutter/material.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/playlist_selection/controller/playlist_selection_controller.dart';
import 'package:youtube/src/feature/playlist_selection/controller/playlist_selection_save_controller.dart';
import 'package:youtube/src/feature/playlist_selection/data/playlist_selection_repository.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/controllers/playlist_selection_data_controller.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/mobile/playlist_selection_mobile_widget.dart';

/// Provides [PlaylistSelectionConfigWidgetState] to the "Select playlist" sheet.
class PlaylistSelectionConfigInhWidget extends InheritedWidget {
  const PlaylistSelectionConfigInhWidget({required this.state, required super.child, super.key});

  final PlaylistSelectionConfigWidgetState state;

  static PlaylistSelectionConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<PlaylistSelectionConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'PlaylistSelectionConfigInhWidget was not found in the widget tree');
    return (widget! as PlaylistSelectionConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant PlaylistSelectionConfigInhWidget oldWidget) => false;
}

/// "Select playlist" bottom sheet: saves [video] into one playlist, or removes it from all.
class PlaylistSelectionConfigWidget extends StatefulWidget {
  const PlaylistSelectionConfigWidget({required this.video, super.key});

  /// Shows the sheet for [video]; completes when it closes.
  static Future<void> show(BuildContext context, {required VideoItem video}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => PlaylistSelectionConfigWidget(video: video),
      );

  final VideoItem video;

  @override
  State<PlaylistSelectionConfigWidget> createState() => PlaylistSelectionConfigWidgetState();
}

class PlaylistSelectionConfigWidgetState extends State<PlaylistSelectionConfigWidget> {
  late final PlaylistSelectionController playlistSelectionController;
  late final PlaylistSelectionSaveController playlistSelectionSaveController;
  late final PlaylistSelectionDataController playlistSelectionDataController;
  late final VideoItem video = widget.video;

  @override
  void initState() {
    super.initState();
    final repository = PlaylistSelectionRepositoryImpl(
      database: DependenciesScope.of(context).database,
    );
    playlistSelectionController = PlaylistSelectionController(
      playlistSelectionRepository: repository,
    )..addListener(_preselectCurrentPlaylist);
    playlistSelectionSaveController = PlaylistSelectionSaveController(
      playlistSelectionRepository: repository,
    );
    playlistSelectionDataController = PlaylistSelectionDataController();
    load();
  }

  @override
  void dispose() {
    playlistSelectionController
      ..removeListener(_preselectCurrentPlaylist)
      ..dispose();
    playlistSelectionSaveController.dispose();
    playlistSelectionDataController.dispose();
    super.dispose();
  }

  void _preselectCurrentPlaylist() {
    if (playlistSelectionController.state case PlaylistSelection$CompletedState(
      :final currentPlaylistId,
    )) {
      playlistSelectionDataController.initialize(currentPlaylistId);
    }
  }

  void load() => playlistSelectionController.load(videoId: video.id);

  /// Whether the ticked playlist differs from the one holding the video.
  bool get hasChanges => switch (playlistSelectionController.state) {
    PlaylistSelection$CompletedState(:final currentPlaylistId) =>
      currentPlaylistId != playlistSelectionDataController.selectedId,
    _ => false,
  };

  /// Saves the ticked playlist; returns false when there is nothing to save.
  bool save() {
    if (!hasChanges) return false;
    playlistSelectionSaveController.save(
      video,
      playlistId: playlistSelectionDataController.selectedId,
    );
    return true;
  }

  @override
  Widget build(BuildContext context) =>
      PlaylistSelectionConfigInhWidget(state: this, child: const PlaylistSelectionMobileWidget());
}
