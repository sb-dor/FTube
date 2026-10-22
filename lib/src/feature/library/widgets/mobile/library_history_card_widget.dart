import 'package:flutter/material.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/widget/channel_avatar_widget.dart';
import 'package:youtube/src/common/widget/network_image_widget.dart';
import 'package:youtube/src/common/widget/video_card_widget.dart';

/// A narrow card of a recently watched video for the library's horizontal history row.
class LibraryHistoryCardWidget extends StatelessWidget {
  const LibraryHistoryCardWidget({
    required this.video,
    required this.onTap,
    required this.onMore,
    super.key,
  });

  static const double width = 150;
  static const double height = 210;

  final VideoItem video;
  final VoidCallback onTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width,
            height: 130,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned.fill(child: NetworkImageWidget(url: video.thumbnail)),
                  if (video.durationText case final duration?)
                    Positioned(bottom: 5, right: 5, child: DurationBadge(text: duration)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.9,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                SizedBox.square(
                  dimension: 24,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 20,
                    onPressed: onMore,
                    icon: const Icon(Icons.more_vert),
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              ChannelAvatarWidget(url: video.channelAvatarUrl, size: 20),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  video.channelName ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
