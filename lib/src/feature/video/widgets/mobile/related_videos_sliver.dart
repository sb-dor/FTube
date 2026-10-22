import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/widget/list_footer_widget.dart';
import 'package:youtube/src/common/widget/video_card_loading_widget.dart';
import 'package:youtube/src/common/widget/video_card_widget.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/video/controller/related_videos_controller.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

/// Similar videos under the player, loading more on scroll.
class RelatedVideosSliver extends StatelessWidget {
  const RelatedVideosSliver({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = VideoConfigInhWidget.of(context);
    return StateConsumer<RelatedVideosController, RelatedVideosState>(
      controller: scope.relatedVideosController,
      builder: (context, state, _) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: switch (state) {
          RelatedVideos$InitialState() => const SliverToBoxAdapter(
            child: VideoListLoadingWidget(count: 3),
          ),
          RelatedVideos$ErrorState() => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                Localization.of(context).videoRelatedError,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          RelatedVideos$CompletedState(:final videos) => SliverList.separated(
            itemCount: videos.length + (state.hasMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 30),
            itemBuilder: (context, index) {
              if (index == videos.length) return const ListFooterWidget();
              final video = videos[index];
              return VideoCardWidget(
                key: ValueKey(video.id),
                video: video,
                onTap: () => scope.openRelated(video),
                onMore: () => PlaylistSelectionConfigWidget.show(context, video: video),
              );
            },
          ),
        },
      ),
    );
  }
}
