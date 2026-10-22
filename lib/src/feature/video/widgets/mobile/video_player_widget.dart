import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/duration_format.dart';
import 'package:youtube/src/common/widget/network_image_widget.dart';
import 'package:youtube/src/feature/video/widgets/controllers/video_playback_controller.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_quality_sheet.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

/// The player area with its controls. [fullscreen] is the landscape page variant.
class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({super.key, this.fullscreen = false});

  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final scope = VideoConfigInhWidget.of(context);
    final playback = scope.videoPlaybackController;
    return ColoredBox(
      color: Colors.black,
      child: ListenableBuilder(
        listenable: playback,
        builder: (context, _) {
          final player = playback.player;
          if (playback.failed) {
            return Center(
              child: Text(
                Localization.of(context).videoPlaybackError,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }
          if (player == null || !playback.isReady) {
            return Stack(
              fit: StackFit.expand,
              children: [
                if (scope.widget.opened?.thumbnail case final thumbnail?)
                  NetworkImageWidget(url: thumbnail),
                const Center(child: CircularProgressIndicator(color: AppColors.accent)),
                if (!fullscreen) _CloseButton(onPressed: scope.close),
              ],
            );
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: playback.toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: player.value.aspectRatio,
                    child: VideoPlayer(player),
                  ),
                ),
                AnimatedOpacity(
                  opacity: playback.controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !playback.controlsVisible,
                    child: _Controls(playback: playback, player: player, fullscreen: fullscreen),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Positioned(
    top: 4,
    left: 4,
    child: IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
    ),
  );
}

class _Controls extends StatelessWidget {
  const _Controls({required this.playback, required this.player, required this.fullscreen});

  final VideoPlaybackController playback;
  final VideoPlayerController player;
  final bool fullscreen;

  Future<void> _toggleFullscreen(BuildContext context) async {
    final scope = VideoConfigInhWidget.of(context);
    if (fullscreen) {
      Navigator.of(context).pop();
      return;
    }
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (!context.mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => VideoConfigInhWidget(
          state: scope,
          child: const Scaffold(
            backgroundColor: Colors.black,
            body: VideoPlayerWidget(fullscreen: true),
          ),
        ),
      ),
    );
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black.withValues(alpha: 0.5),
    child: SafeArea(
      top: fullscreen,
      bottom: fullscreen,
      child: Stack(
        children: [
          if (!fullscreen) _CloseButton(onPressed: VideoConfigInhWidget.of(context).close),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              onPressed: playback.qualities.length < 2
                  ? null
                  : () => showVideoQualitySheet(context, playback),
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ),
          Center(
            child: ValueListenableBuilder(
              valueListenable: player,
              builder: (context, value, _) => IconButton(
                iconSize: 56,
                onPressed: playback.togglePlay,
                icon: Icon(
                  value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            right: 4,
            bottom: 0,
            child: ValueListenableBuilder(
              valueListenable: player,
              builder: (context, value, _) => Row(
                children: [
                  Text(formatDuration(value.position), style: const TextStyle(color: Colors.white)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: VideoProgressIndicator(
                      player,
                      allowScrubbing: true,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      colors: const VideoProgressColors(
                        playedColor: AppColors.accent,
                        bufferedColor: Colors.white60,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(formatDuration(value.duration), style: const TextStyle(color: Colors.white)),
                  IconButton(
                    onPressed: () => _toggleFullscreen(context),
                    icon: Icon(
                      fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
