import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/widget/channel_avatar_widget.dart';
import 'package:youtube/src/common/widget/network_image_widget.dart';

/// Wraps a card's thumbnail layer, e.g. to play a preview over it.
typedef ThumbnailWrapper = Widget Function(BuildContext context, Widget thumbnail);

/// A full-width video card: thumbnail with view and duration badges, a "more" button, and the
/// channel avatar with title and channel line underneath.
class VideoCardWidget extends StatelessWidget {
  const VideoCardWidget({
    required this.video,
    required this.onTap,
    super.key,
    this.onMore,
    this.thumbnailWrapper,
  });

  static const double thumbnailHeight = 180;

  final VideoItem video;
  final VoidCallback onTap;

  /// Opens the playlist menu for this video; the button is hidden when null.
  final VoidCallback? onMore;

  /// Wraps the thumbnail image layer (below the badges).
  final ThumbnailWrapper? thumbnailWrapper;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final thumbnail = NetworkImageWidget(url: video.thumbnail);
    final subtitle = [
      ?video.channelName,
      if (video.isLive) l10n.live else ?video.publishedText,
    ].join('  •  ');
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      // A long hold is the preview gesture, not a tap.
      onLongPress: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: thumbnailHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Positioned.fill(child: thumbnailWrapper?.call(context, thumbnail) ?? thumbnail),
                  Positioned(
                    top: 5,
                    left: 10,
                    child: _ViewsBadge(text: video.isLive ? l10n.live : video.viewsText),
                  ),
                  if (onMore case final onMore?)
                    Positioned(
                      top: 5,
                      right: 10,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.2),
                        ),
                        onPressed: onMore,
                        icon: const Icon(Icons.more_horiz, color: Colors.white),
                      ),
                    ),
                  if (!video.isLive && video.durationText != null)
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: DurationBadge(text: video.durationText!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (video.channelAvatarUrl != null) ...[
                ChannelAvatarWidget(url: video.channelAvatarUrl),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewsBadge extends StatelessWidget {
  const _ViewsBadge({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.remove_red_eye_outlined, size: 20, color: Colors.white),
          if (text case final text?) ...[
            const SizedBox(width: 5),
            Text(
              text,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Black rounded badge with a duration or playback position.
class DurationBadge extends StatelessWidget {
  const DurationBadge({required this.text, super.key});

  final String text;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(3)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10)),
    ),
  );
}
