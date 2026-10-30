import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/utils/duration_format.dart';
import 'package:youtube/src/common/widget/duration_badge.dart';

/// Stop and sound buttons over a playing preview, with its position.
class VideoPreviewControlsWidget extends StatelessWidget {
  const VideoPreviewControlsWidget({required this.player, required this.onStop, super.key});

  final VideoPlayerController player;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: player,
    builder: (context, value, _) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RoundButton(icon: Icons.play_disabled, onTap: onStop),
        const SizedBox(height: 4),
        _RoundButton(
          icon: value.volume == 0 ? Icons.volume_up_sharp : Icons.volume_off_sharp,
          onTap: () => player.setVolume(value.volume == 0 ? 1 : 0),
        ),
        const SizedBox(height: 4),
        DurationBadge(text: formatDuration(value.position)),
      ],
    ),
  );
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: 0.5),
    shape: const CircleBorder(),
    child: InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 15),
      ),
    ),
  );
}
