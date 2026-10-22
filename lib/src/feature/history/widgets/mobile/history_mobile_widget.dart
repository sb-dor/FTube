import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/widget/empty_state_widget.dart';
import 'package:youtube/src/common/widget/list_footer_widget.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/common/widget/video_row_widget.dart';
import 'package:youtube/src/feature/history/controller/history_controller.dart';
import 'package:youtube/src/feature/history/widgets/history_config_widget.dart';
import 'package:youtube/src/feature/history/widgets/mobile/video_row_loading_widget.dart';
import 'package:youtube/src/feature/history_deletion/widgets/history_deletion_config_widget.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

class HistoryMobileWidget extends StatefulWidget {
  const HistoryMobileWidget({super.key});

  @override
  State<HistoryMobileWidget> createState() => _HistoryMobileWidgetState();
}

class _HistoryMobileWidgetState extends State<HistoryMobileWidget> {
  late final _scope = HistoryConfigInhWidget.of(context);
  late final _controller = _scope.historyController;
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
    return StateConsumer<HistoryController, HistoryState>(
      controller: _controller,
      builder: (context, state, _) => Scaffold(
        appBar: AppBar(
          title: Text(l10n.historyTitle),
          scrolledUnderElevation: 0,
          actions: [
            if (state case History$CompletedState(:final videos) when videos.isNotEmpty)
              IconButton(
                tooltip: l10n.historyClear,
                onPressed: () => HistoryDeletionConfigWidget.show(context),
                icon: const Icon(Icons.delete_sweep_outlined),
              ),
          ],
        ),
        body: switch (state) {
          History$InitialState() || History$InProgressState() => const SingleChildScrollView(
            physics: NeverScrollableScrollPhysics(),
            child: VideoRowLoadingWidget(),
          ),
          History$ErrorState() => Center(child: TryAgainButton(onPressed: _scope.load)),
          History$CompletedState(:final videos) when videos.isEmpty => Center(
            child: EmptyStateWidget(message: l10n.historyEmpty),
          ),
          History$CompletedState(:final videos, :final hasMore) => ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            itemCount: videos.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == videos.length) return const ListFooterWidget();
              final video = videos[index];
              return _HistoryRow(key: ValueKey(video.id), video: video);
            },
          ),
        },
      ),
    );
  }
}

enum _HistoryRowAction { remove, addToPlaylist }

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.video, super.key});

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
      trailing: PopupMenuButton<_HistoryRowAction>(
        icon: const Icon(Icons.more_vert, size: 20),
        onSelected: (action) => switch (action) {
          _HistoryRowAction.remove => HistoryDeletionConfigWidget.show(context, videoId: video.id),
          _HistoryRowAction.addToPlaylist => PlaylistSelectionConfigWidget.show(
            context,
            video: video,
          ),
        },
        itemBuilder: (context) => [
          PopupMenuItem(value: _HistoryRowAction.remove, child: Text(l10n.historyRemove)),
          PopupMenuItem(
            value: _HistoryRowAction.addToPlaylist,
            child: Text(l10n.playlistSelectionAction),
          ),
        ],
      ),
    );
  }
}
