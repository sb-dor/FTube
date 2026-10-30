import 'package:flutter/material.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/widget/empty_state_widget.dart';
import 'package:youtube/src/common/widget/list_footer_widget.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/common/widget/video_card_loading_widget.dart';
import 'package:youtube/src/common/widget/video_card_widget.dart';

/// A paginated list of video cards as a sliver, with its loading, error and empty states
/// (home feed, trending, search results).
class VideoSliverListWidget extends StatelessWidget {
  const VideoSliverListWidget({
    required this.videos,
    required this.inProgress,
    required this.hasError,
    required this.hasMore,
    required this.onRetry,
    required this.onVideoTap,
    super.key,
    this.onVideoMore,
    this.thumbnailWrapper,
    this.emptyMessage,
    this.firstCardKey,
  });

  final List<VideoItem> videos;

  /// Shows card placeholders instead of the list.
  final bool inProgress;

  /// Shows a retry button instead of the list.
  final bool hasError;

  /// Shows a spinner under the list while the next page loads.
  final bool hasMore;

  final VoidCallback onRetry;
  final ValueChanged<VideoItem> onVideoTap;
  final ValueChanged<VideoItem>? onVideoMore;

  /// Wraps a video's thumbnail, e.g. to play a preview over it.
  final Widget Function(BuildContext context, VideoItem video, Widget thumbnail)? thumbnailWrapper;

  /// Shown when [videos] is empty; defaults to the generic empty-list message.
  final String? emptyMessage;

  /// Key for the first card, e.g. to point a hint at it.
  final GlobalKey? firstCardKey;

  @override
  Widget build(BuildContext context) {
    if (inProgress) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverToBoxAdapter(child: VideoListLoadingWidget()),
      );
    }
    if (hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: TryAgainButton(onPressed: onRetry)),
      );
    }
    if (videos.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: EmptyStateWidget(message: emptyMessage)),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverList.separated(
        itemCount: videos.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: 30),
        itemBuilder: (context, index) {
          if (index == videos.length) return const ListFooterWidget();
          final video = videos[index];
          final wrapper = thumbnailWrapper;
          final onMore = onVideoMore;
          return VideoCardWidget(
            key: index == 0 && firstCardKey != null ? firstCardKey : ValueKey(video.id),
            video: video,
            onTap: () => onVideoTap(video),
            onMore: onMore == null ? null : () => onMore(video),
            thumbnailWrapper: wrapper == null
                ? null
                : (context, thumbnail) => wrapper(context, video, thumbnail),
          );
        },
      ),
    );
  }
}
