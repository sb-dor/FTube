import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/controller_extensions.dart';
import 'package:youtube/src/common/widget/category_chips_widget.dart';
import 'package:youtube/src/common/widget/video_card_widget.dart';
import 'package:youtube/src/common/widget/video_sliver_list_widget.dart';
import 'package:youtube/src/feature/feed/controller/feed_controller.dart';
import 'package:youtube/src/feature/feed/models/feed_category.dart';
import 'package:youtube/src/feature/feed/widgets/feed_config_widget.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/preview_hint/widgets/preview_hint_config_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';
import 'package:youtube/src/feature/video_preview/widgets/video_preview_config_widget.dart';

class FeedMobileWidget extends StatefulWidget {
  const FeedMobileWidget({super.key});

  @override
  State<FeedMobileWidget> createState() => _FeedMobileWidgetState();
}

class _FeedMobileWidgetState extends State<FeedMobileWidget> {
  late final _scope = FeedConfigInhWidget.of(context);
  late final _controller = _scope.feedController;
  late final _dataController = _scope.feedDataController;
  final _scrollController = ScrollController();
  final _firstCardKey = GlobalKey();
  bool _hintChecked = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _controller.addListener(_maybeShowHint);
  }

  @override
  void dispose() {
    _controller.removeListener(_maybeShowHint);
    _scrollController.dispose();
    super.dispose();
  }

  /// Once the first videos are on screen, explains hold-to-preview over the first card.
  void _maybeShowHint() {
    final state = _controller.state;
    if (_hintChecked || state is! Feed$CompletedState || state.videos.isEmpty) return;
    _hintChecked = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final box = _firstCardKey.currentContext?.findRenderObject() as RenderBox?;
      if (!mounted || box == null || !box.hasSize) return;
      final origin = box.localToGlobal(Offset.zero);
      final inset = MediaQuery.sizeOf(context).width * VideoPreviewConfigWidget.sideInsetFactor;
      PreviewHintConfigWidget.showIfNeeded(
        context,
        target: Rect.fromLTRB(
          origin.dx + inset,
          origin.dy,
          origin.dx + box.size.width - inset,
          origin.dy + VideoCardWidget.thumbnailHeight,
        ),
      );
    });
  }

  void _onScroll() {
    final position = _scrollController.position;
    if (position.pixels < position.maxScrollExtent - 600) return;
    if (_controller.isProcessing || !_controller.state.hasMore) return;
    _scope.paginate();
  }

  Future<void> _refresh() {
    _scope.load();
    return _controller.waitFor((state) => state is! Feed$InProgressState);
  }

  void _selectCategory(FeedCategory category) {
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
              builder: (context, _) => CategoryChipsWidget<FeedCategory>(
                values: FeedCategory.values,
                selected: _dataController.category,
                label: (category) => category.label(Localization.of(context)),
                onSelected: _selectCategory,
              ),
            ),
          ),
        ),
        StateConsumer<FeedController, FeedState>(
          controller: _controller,
          builder: (context, state, _) => VideoSliverListWidget(
            videos: switch (state) {
              Feed$CompletedState(:final videos) => videos,
              _ => const [],
            },
            inProgress: state is Feed$InitialState || state is Feed$InProgressState,
            hasError: state is Feed$ErrorState,
            hasMore: state.hasMore,
            firstCardKey: _firstCardKey,
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
