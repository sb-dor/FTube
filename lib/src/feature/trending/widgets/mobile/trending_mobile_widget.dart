import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/common/widget/category_chips_widget.dart';
import 'package:youtube/src/common/widget/video_sliver_list_widget.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/trending/controller/trending_controller.dart';
import 'package:youtube/src/feature/trending/models/trending_category.dart';
import 'package:youtube/src/feature/trending/widgets/trending_config_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';
import 'package:youtube/src/feature/video_preview/widgets/video_preview_config_widget.dart';

class TrendingMobileWidget extends StatefulWidget {
  const TrendingMobileWidget({super.key});

  @override
  State<TrendingMobileWidget> createState() => _TrendingMobileWidgetState();
}

class _TrendingMobileWidgetState extends State<TrendingMobileWidget> {
  late final _scope = TrendingConfigInhWidget.of(context);
  late final _controller = _scope.trendingController;
  late final _dataController = _scope.trendingDataController;
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
    return _controller.waitFor((state) => state is! Trending$InProgressState);
  }

  void _selectCategory(TrendingCategory category) {
    if (!_scope.selectCategory(category)) return;
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: AppColors.accent,
    onRefresh: _refresh,
    child: CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          sliver: SliverToBoxAdapter(
            child: ListenableBuilder(
              listenable: _dataController,
              builder: (context, _) => CategoryChipsWidget<TrendingCategory>(
                values: TrendingCategory.values,
                selected: _dataController.category,
                label: (category) => category.label(Localization.of(context)),
                onSelected: _selectCategory,
              ),
            ),
          ),
        ),
        StateConsumer<TrendingController, TrendingState>(
          controller: _controller,
          builder: (context, state, _) => VideoSliverListWidget(
            videos: switch (state) {
              Trending$CompletedState(:final videos) => videos,
              _ => const [],
            },
            inProgress: state is Trending$InitialState || state is Trending$InProgressState,
            hasError: state is Trending$ErrorState,
            hasMore: state.hasMore,
            onRetry: _scope.load,
            onVideoTap: (video) => VideoConfigWidget.open(context, video: video),
            onVideoMore: (video) => PlaylistSelectionConfigWidget.show(context, video: video),
            thumbnailWrapper: (context, video, thumbnail) =>
                VideoPreviewConfigWidget(video: video, child: thumbnail),
          ),
        ),
        // Room for the floating bottom bar.
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    ),
  );
}
