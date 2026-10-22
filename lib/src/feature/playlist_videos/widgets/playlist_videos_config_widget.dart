import 'package:flutter/material.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/playlist_videos/controller/playlist_videos_controller.dart';
import 'package:youtube/src/feature/playlist_videos/data/playlist_videos_repository.dart';
import 'package:youtube/src/feature/playlist_videos/widgets/mobile/playlist_videos_mobile_widget.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

/// Provides [PlaylistVideosConfigWidgetState] to the playlist videos screen.
class PlaylistVideosConfigInhWidget extends InheritedWidget {
  const PlaylistVideosConfigInhWidget({required this.state, required super.child, super.key});

  final PlaylistVideosConfigWidgetState state;

  static PlaylistVideosConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<PlaylistVideosConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'PlaylistVideosConfigInhWidget was not found in the widget tree');
    return (widget! as PlaylistVideosConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant PlaylistVideosConfigInhWidget oldWidget) => false;
}

/// The videos of one playlist, or of the virtual "Liked videos" playlist.
class PlaylistVideosConfigWidget extends StatefulWidget {
  const PlaylistVideosConfigWidget({required this.playlist, super.key});

  static Future<void> open(BuildContext context, {required PlaylistSummary playlist}) =>
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (context) => PlaylistVideosConfigWidget(playlist: playlist),
        ),
      );

  final PlaylistSummary playlist;

  @override
  State<PlaylistVideosConfigWidget> createState() => PlaylistVideosConfigWidgetState();
}

class PlaylistVideosConfigWidgetState extends State<PlaylistVideosConfigWidget> {
  late final PlaylistVideosController playlistVideosController;
  late final PlaylistSummary playlist = widget.playlist;

  @override
  void initState() {
    super.initState();
    playlistVideosController = PlaylistVideosController(
      playlistVideosRepository: PlaylistVideosRepositoryImpl(
        database: DependenciesScope.of(context).database,
      ),
    );
    load();
  }

  @override
  void dispose() {
    playlistVideosController.dispose();
    super.dispose();
  }

  void load() => playlistVideosController.load(playlist: playlist);

  void paginate() => playlistVideosController.paginate(playlist: playlist);

  @override
  Widget build(BuildContext context) =>
      PlaylistVideosConfigInhWidget(state: this, child: const PlaylistVideosMobileWidget());
}
