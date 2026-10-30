import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/common/widget/video_sliver_list_widget.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/search/controller/search_results_controller.dart';
import 'package:youtube/src/feature/search/widgets/search_config_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';
import 'package:youtube/src/feature/video_preview/widgets/video_preview_config_widget.dart';

/// Paginated search results with pull-to-refresh.
class SearchResultsWidget extends StatefulWidget {
  const SearchResultsWidget({super.key});

  @override
  State<SearchResultsWidget> createState() => _SearchResultsWidgetState();
}

class _SearchResultsWidgetState extends State<SearchResultsWidget> {
  late final _scope = SearchConfigInhWidget.of(context);
  late final _controller = _scope.searchResultsController;
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
    if (position.pixels < position.maxScrollExtent - 600) return;
    if (_controller.isProcessing || !_controller.state.hasMore) return;
    _scope.paginate();
  }

  Future<void> _refresh() {
    _scope.load();
    return _controller.waitFor((state) => state is! SearchResults$InProgressState);
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: AppColors.accent,
    onRefresh: _refresh,
    child: CustomScrollView(
      controller: _scrollController,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        const SliverToBoxAdapter(child: SizedBox(height: 10)),
        StateConsumer<SearchResultsController, SearchResultsState>(
          controller: _controller,
          listener: (context, controller, previous, next) {
            // A new search starts at the top.
            if (next is SearchResults$InProgressState && _scrollController.hasClients) {
              _scrollController.jumpTo(0);
            }
          },
          builder: (context, state, _) => VideoSliverListWidget(
            videos: switch (state) {
              SearchResults$CompletedState(:final videos) => videos,
              _ => const [],
            },
            inProgress:
                state is SearchResults$InitialState || state is SearchResults$InProgressState,
            hasError: state is SearchResults$ErrorState,
            hasMore: state.hasMore,
            emptyMessage: Localization.of(context).searchNoResults,
            onRetry: _scope.load,
            onVideoTap: (video) => VideoConfigWidget.open(context, video: video),
            onVideoMore: (video) => PlaylistSelectionConfigWidget.show(context, video: video),
            thumbnailWrapper: (context, video, thumbnail) =>
                VideoPreviewConfigWidget(video: video, child: thumbnail),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 10 + MediaQuery.paddingOf(context).bottom)),
      ],
    ),
  );
}
