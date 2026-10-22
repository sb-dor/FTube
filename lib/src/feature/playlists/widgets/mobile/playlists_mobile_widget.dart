import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/widget/empty_state_widget.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/playlist_creation_config_widget.dart';
import 'package:youtube/src/feature/playlist_deletion/widgets/playlist_deletion_config_widget.dart';
import 'package:youtube/src/feature/playlist_videos/widgets/playlist_videos_config_widget.dart';
import 'package:youtube/src/feature/playlists/controller/playlists_controller.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';
import 'package:youtube/src/feature/playlists/widgets/playlist_card_widget.dart';
import 'package:youtube/src/feature/playlists/widgets/playlists_config_widget.dart';

class PlaylistsMobileWidget extends StatefulWidget {
  const PlaylistsMobileWidget({super.key});

  @override
  State<PlaylistsMobileWidget> createState() => _PlaylistsMobileWidgetState();
}

class _PlaylistsMobileWidgetState extends State<PlaylistsMobileWidget> {
  late final _scope = PlaylistsConfigInhWidget.of(context);
  late final _controller = _scope.playlistsController;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.playlistsTitle),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: l10n.playlistCreationTitle,
            onPressed: () => PlaylistCreationConfigWidget.show(context),
            icon: const Icon(Icons.add, color: AppColors.accent),
          ),
        ],
      ),
      body: StateConsumer<PlaylistsController, PlaylistsState>(
        controller: _controller,
        builder: (context, state, _) => switch (state) {
          Playlists$InitialState() ||
          Playlists$InProgressState() => const Center(child: CircularProgressIndicator()),
          Playlists$ErrorState() => Center(child: TryAgainButton(onPressed: _scope.watch)),
          Playlists$CompletedState(:final playlists) when playlists.isEmpty => Center(
            child: EmptyStateWidget(message: l10n.playlistsEmpty),
          ),
          Playlists$CompletedState(:final playlists) => GridView.builder(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 185,
              crossAxisSpacing: 10,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) => _PlaylistGridItem(playlist: playlists[index]),
          ),
        },
      ),
    );
  }
}

class _PlaylistGridItem extends StatelessWidget {
  const _PlaylistGridItem({required this.playlist});

  final PlaylistSummary playlist;

  void _delete(BuildContext context, UserPlaylistSummary playlist) =>
      PlaylistDeletionConfigWidget.show(context, playlistId: playlist.id, name: playlist.name);

  @override
  Widget build(BuildContext context) {
    final playlist = this.playlist;
    return Center(
      child: PlaylistCardWidget(
        playlist: playlist,
        centered: true,
        onTap: () => PlaylistVideosConfigWidget.open(context, playlist: playlist),
        onLongPress: switch (playlist) {
          final UserPlaylistSummary user => () => _delete(context, user),
          LikedPlaylistSummary() => null,
        },
        trailing: switch (playlist) {
          final UserPlaylistSummary user => SizedBox.square(
            dimension: 24,
            child: PopupMenuButton<void>(
              padding: EdgeInsets.zero,
              iconSize: 20,
              icon: const Icon(Icons.more_vert),
              itemBuilder: (context) => [
                PopupMenuItem<void>(
                  onTap: () => _delete(context, user),
                  child: Text(Localization.of(context).playlistDeletionAction),
                ),
              ],
            ),
          ),
          LikedPlaylistSummary() => null,
        },
      ),
    );
  }
}
