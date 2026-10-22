import 'package:flutter/material.dart';
import 'package:youtube/src/common/widget/network_image_widget.dart';
import 'package:youtube/src/common/widget/video_card_widget.dart';

/// Compact video row: thumbnail on the left, title, channel and views on the right.
/// Used by history, playlists and downloads.
class VideoRowWidget extends StatelessWidget {
  const VideoRowWidget({
    required this.title,
    required this.onTap,
    super.key,
    this.thumbnailUrl,
    this.channelName,
    this.viewsText,
    this.durationText,
    this.badge,
    this.trailing,
  });

  final String title;
  final String? thumbnailUrl;
  final String? channelName;
  final String? viewsText;
  final String? durationText;

  /// Shown over the top-left corner of the thumbnail, e.g. a file type.
  final String? badge;

  /// Shown at the end of the row, e.g. a menu button.
  final Widget? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: MediaQuery.sizeOf(context).width / 2.1,
              height: 110,
              child: Stack(
                children: [
                  Positioned.fill(child: NetworkImageWidget(url: thumbnailUrl)),
                  if (durationText case final duration?)
                    Positioned(bottom: 6, right: 6, child: DurationBadge(text: duration)),
                  if (badge case final badge?)
                    Positioned(top: 6, left: 6, child: DurationBadge(text: badge)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                if (channelName case final channel?)
                  Text(channel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                if (viewsText case final views?)
                  Text(views, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}
