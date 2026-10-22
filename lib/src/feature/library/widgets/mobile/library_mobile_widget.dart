import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/widget/empty_state_widget.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/feature/downloads/widgets/downloads_config_widget.dart';
import 'package:youtube/src/feature/history/widgets/history_config_widget.dart';
import 'package:youtube/src/feature/library/controller/library_controller.dart';
import 'package:youtube/src/feature/library/models/library_overview.dart';
import 'package:youtube/src/feature/library/widgets/library_config_widget.dart';
import 'package:youtube/src/feature/library/widgets/mobile/library_downloads_tile_widget.dart';
import 'package:youtube/src/feature/library/widgets/mobile/library_history_card_widget.dart';
import 'package:youtube/src/feature/library/widgets/mobile/library_loading_widget.dart';
import 'package:youtube/src/feature/library/widgets/mobile/library_section_header_widget.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/playlist_creation_config_widget.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/playlist_videos/widgets/playlist_videos_config_widget.dart';
import 'package:youtube/src/feature/playlists/widgets/playlist_card_widget.dart';
import 'package:youtube/src/feature/playlists/widgets/playlists_config_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

class LibraryMobileWidget extends StatefulWidget {
  const LibraryMobileWidget({super.key});

  @override
  State<LibraryMobileWidget> createState() => _LibraryMobileWidgetState();
}

class _LibraryMobileWidgetState extends State<LibraryMobileWidget> {
  late final _scope = LibraryConfigInhWidget.of(context);
  late final _controller = _scope.libraryController;

  @override
  Widget build(BuildContext context) => StateConsumer<LibraryController, LibraryState>(
    controller: _controller,
    builder: (context, state, _) => switch (state) {
      Library$InitialState() || Library$InProgressState() => const LibraryLoadingWidget(),
      Library$ErrorState() => Center(child: TryAgainButton(onPressed: _scope.watch)),
      Library$CompletedState(:final overview) => _LibraryContent(overview: overview),
    },
  );
}

class _LibraryContent extends StatelessWidget {
  const _LibraryContent({required this.overview});

  final LibraryOverview overview;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final history = overview.history;
    final playlists = overview.playlists;
    return ListView(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      children: [
        if (history.isNotEmpty) ...[
          LibrarySectionHeaderWidget(
            title: l10n.historyTitle,
            onSeeAll: () => HistoryConfigWidget.open(context),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: LibraryHistoryCardWidget.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: history.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final video = history[index];
                return LibraryHistoryCardWidget(
                  key: ValueKey(video.id),
                  video: video,
                  onTap: () => VideoConfigWidget.open(context, video: video),
                  onMore: () => PlaylistSelectionConfigWidget.show(context, video: video),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
        LibrarySectionHeaderWidget(
          title: l10n.playlistsTitle,
          onAdd: () => PlaylistCreationConfigWidget.show(context),
          addTooltip: l10n.playlistCreationTitle,
          onSeeAll: playlists.isEmpty ? null : () => PlaylistsConfigWidget.open(context),
        ),
        if (playlists.isNotEmpty) ...[
          const SizedBox(height: 15),
          SizedBox(
            height: 165,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: playlists.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return PlaylistCardWidget(
                  playlist: playlist,
                  onTap: () => PlaylistVideosConfigWidget.open(context, playlist: playlist),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
        ],
        if (overview.downloadsCount > 0)
          LibraryDownloadsTileWidget(
            count: overview.downloadsCount,
            onTap: () => DownloadsConfigWidget.open(context),
          ),
        if (history.isEmpty && playlists.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: EmptyStateWidget(message: l10n.libraryEmpty),
          ),
        // Room for the floating bottom bar.
        const SizedBox(height: 100),
      ],
    );
  }
}
