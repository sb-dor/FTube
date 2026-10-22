import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/widget/network_image_widget.dart';
import 'package:youtube/src/feature/playlists/models/playlist_summary.dart';

/// A playlist card: a stacked cover with the newest video's thumbnail, the video count and the
/// name underneath. Used by the library tab and the playlists grid.
class PlaylistCardWidget extends StatelessWidget {
  const PlaylistCardWidget({
    required this.playlist,
    required this.onTap,
    super.key,
    this.onLongPress,
    this.trailing,
    this.centered = false,
  });

  static const double width = 150;
  static const double coverHeight = 130;

  final PlaylistSummary playlist;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Shown after the name, e.g. a menu button.
  final Widget? trailing;

  /// Centers the card in its cell (grid layout).
  final bool centered;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    onLongPress: onLongPress,
    child: Column(
      crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          height: coverHeight,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 15,
                right: 15,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                left: 0,
                right: 0,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: playlist.videoCount == 0
                        ? Image.asset('assets/custom_images/empty_data.png')
                        : _Cover(playlist: playlist),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: width,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  playlist.title(Localization.of(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: centered && trailing == null ? TextAlign.center : TextAlign.start,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.9,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ],
    ),
  );
}

class _Cover extends StatelessWidget {
  const _Cover({required this.playlist});

  final PlaylistSummary playlist;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      NetworkImageWidget(url: playlist.thumbnailUrl),
      ColoredBox(
        color: Colors.black.withValues(alpha: 0.3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ondemand_video_sharp, color: Colors.white),
            Text('${playlist.videoCount}', style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    ],
  );
}
