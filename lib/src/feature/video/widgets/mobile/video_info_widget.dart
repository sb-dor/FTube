import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/widget/channel_avatar_widget.dart';
import 'package:youtube/src/common/widget/shimmer_box.dart';
import 'package:youtube/src/common/widget/try_again_button.dart';
import 'package:youtube/src/feature/video/controller/video_controller.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';
import 'package:youtube/src/feature/video_download/widgets/video_download_button.dart';

/// Title, views and date, channel, description and the download button.
class VideoInfoWidget extends StatelessWidget {
  const VideoInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = VideoConfigInhWidget.of(context);
    return StateConsumer<VideoController, VideoState>(
      controller: scope.videoController,
      builder: (context, state, _) => switch (state) {
        Video$InitialState() || Video$InProgressState() => const _InfoLoading(),
        Video$ErrorState() => TryAgainButton(
          message: Localization.of(context).videoInfoError,
          onPressed: scope.retry,
        ),
        Video$CompletedState(:final details) => Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                details.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                [?details.viewsText, ?details.publishedText].join(' • '),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ChannelAvatarWidget(url: details.channelAvatarUrl, size: 35),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [?details.channelName, ?details.subscribersText].join(' • '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  VideoDownloadButton(video: scope.video),
                ],
              ),
              if (details.description case final description? when description.isNotEmpty)
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(
                      Localization.of(context).videoMoreInfo,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    expandedCrossAxisAlignment: CrossAxisAlignment.start,
                    children: [SelectableText(description)],
                  ),
                ),
            ],
          ),
        ),
      },
    );
  }
}

class _InfoLoading extends StatelessWidget {
  const _InfoLoading();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: width, height: 18, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 8),
          ShimmerBox(width: width * 0.6, height: 14, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 14),
          Row(
            children: [
              ShimmerBox(width: 35, height: 35, borderRadius: BorderRadius.circular(35)),
              const SizedBox(width: 8),
              Expanded(child: ShimmerBox(height: 14, borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 60),
              ShimmerBox(width: 100, height: 36, borderRadius: BorderRadius.circular(20)),
            ],
          ),
        ],
      ),
    );
  }
}
