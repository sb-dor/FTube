import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/youtube_link.dart';
import 'package:youtube/src/feature/playlist_selection/widgets/playlist_selection_config_widget.dart';
import 'package:youtube/src/feature/video/controller/video_bookmark_controller.dart';
import 'package:youtube/src/feature/video/controller/video_controller.dart';
import 'package:youtube/src/feature/video/controller/video_like_controller.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

/// Like, dislike, share and bookmark buttons above a curved divider.
class VideoActionsWidget extends StatelessWidget {
  const VideoActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = VideoConfigInhWidget.of(context);
    final l10n = Localization.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: StateConsumer<VideoLikeController, VideoLikeState>(
              controller: scope.videoLikeController,
              builder: (context, likeState, _) {
                final liked = likeState is VideoLike$ReadyState && likeState.liked;
                return StateConsumer<VideoController, VideoState>(
                  controller: scope.videoController,
                  builder: (context, videoState, _) => _ActionButton(
                    icon: liked ? FontAwesomeIcons.solidThumbsUp : FontAwesomeIcons.thumbsUp,
                    color: liked ? AppColors.accent : Colors.grey,
                    label: switch (videoState) {
                      Video$CompletedState(:final details) => details.likesText ?? '',
                      _ => '',
                    },
                    onTap: videoState is Video$CompletedState
                        ? () => scope.videoLikeController.toggle(scope.video)
                        : null,
                  ),
                );
              },
            ),
          ),
          const Expanded(
            child: _ActionButton(icon: FontAwesomeIcons.thumbsDown, color: Colors.grey, label: ''),
          ),
          Expanded(
            child: _ActionButton(
              icon: FontAwesomeIcons.share,
              color: Colors.grey,
              label: l10n.videoShare,
              onTap: () =>
                  SharePlus.instance.share(ShareParams(uri: videoShareLink(scope.videoId))),
            ),
          ),
          Expanded(
            child: StateConsumer<VideoBookmarkController, bool>(
              controller: scope.videoBookmarkController,
              builder: (context, saved, _) => _ActionButton(
                icon: saved ? FontAwesomeIcons.solidBookmark : FontAwesomeIcons.bookmark,
                color: saved ? AppColors.accent : Colors.grey,
                label: l10n.videoToBookmarks,
                onTap: () => PlaylistSelectionConfigWidget.show(context, video: scope.video),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.color, required this.label, this.onTap});

  final FaIconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          FaIcon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),
        ],
      ),
    ),
  );
}
