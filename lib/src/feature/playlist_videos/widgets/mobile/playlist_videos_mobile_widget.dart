import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/widget/empty_state_widget.dart';
import 'package:youtube/src/common/widget/list_footer_widget.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/common/widget/video_row_widget.dart';
import 'package:youtube/src/feature/history/widgets/mobile/video_row_loading_widget.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/playlist_video_removal/widgets/playlist_video_removal_config_widget.dart';
import 'package:youtube/src/feature/playlist_videos/controller/playlist_videos_controller.dart';
import 'package:youtube/src/feature/playlist_videos/widgets/playlist_videos_config_widget.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

class PlaylistVideosMobileWidget extends StatefulWidget {
  const PlaylistVideosMobileWidget({super.key});

  @override
  State<PlaylistVideosMobileWidget> createState() => _PlaylistVideosMobileWidgetState();
}

class _PlaylistVideosMobileWidgetState extends State<PlaylistVideosMobileWidget> {
  late final _scope = PlaylistVideosConfigInhWidget.of(context);
  late final _controller = _scope.playlistVideosController;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 400) return;
    if (_controller.isProcessing || !_controller.state.canLoadMore) return;
    _scope.paginate();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_scope.playlist.title(l10n), maxLines: 1, overflow: TextOverflow.ellipsis),
        scrolledUnderElevation: 0,
      ),
      body: StateConsumer<PlaylistVideosController, PlaylistVideosState>(
        controller: _controller,
        builder: (context, state, _) => switch (state) {
          PlaylistVideos$InitialState() ||
          PlaylistVideos$InProgressState() => const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: VideoRowLoadingWidget(),
          ),
          PlaylistVideos$ErrorState() => Center(child: TryAgainButton(onPressed: _scope.load)),
          PlaylistVideos$CompletedState(:final videos) when videos.isEmpty => Center(
            child: EmptyStateWidget(message: l10n.playlistVideosEmpty),
          ),
          PlaylistVideos$CompletedState(:final videos, :final hasMore) => ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            itemCount: videos.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == videos.length) return const ListFooterWidget();
              final video = videos[index];
              return _PlaylistVideoRow(
                key: ValueKey(video.id),
                playlist: _scope.playlist,
                video: video,
              );
            },
          ),
        },
      ),
    );
  }
}

enum _PlaylistVideoAction { remove, addToPlaylist }

class _PlaylistVideoRow extends StatelessWidget {
  const _PlaylistVideoRow({required this.playlist, required this.video, super.key});

  final PlaylistSummary playlist;
  final VideoItem video;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return VideoRowWidget(
      title: video.title,
      thumbnailUrl: video.thumbnail,
      channelName: video.channelName,
      viewsText: video.viewsText,
      durationText: video.durationText,
      onTap: () => VideoConfigWidget.open(context, video: video),
      trailing: PopupMenuButton<_PlaylistVideoAction>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (action) => switch (action) {
          _PlaylistVideoAction.remove => PlaylistVideoRemovalConfigWidget.show(
            context,
            playlist: playlist,
            video: video,
          ),
          _PlaylistVideoAction.addToPlaylist => PlaylistSelectionConfigWidget.show(
            context,
            video: video,
          ),
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _PlaylistVideoAction.remove,
            child: Text(switch (playlist) {
              UserPlaylistSummary() => l10n.playlistVideoRemovalAction,
              LikedPlaylistSummary() => l10n.playlistVideoRemovalUnlikeAction,
            }),
          ),
          PopupMenuItem(
            value: _PlaylistVideoAction.addToPlaylist,
            child: Text(l10n.playlistSelectionAction),
          ),
        ],
      ),
    );
  }
}
