import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/duration_format.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_player_close_button.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_player_widget.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_quality_sheet.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

/// Close, quality, play-pause, progress and full-screen controls over the playing [video].
/// [fullscreen] is the landscape page variant.
class VideoPlayerControlsWidget extends StatefulWidget {
  const VideoPlayerControlsWidget({required this.video, required this.fullscreen, super.key});

  final VideoPlayerController video;
  final bool fullscreen;

  @override
  State<VideoPlayerControlsWidget> createState() => _VideoPlayerControlsWidgetState();
}

class _VideoPlayerControlsWidgetState extends State<VideoPlayerControlsWidget> {
  late final _scope = VideoConfigInhWidget.of(context);

  /// Opens the player as a landscape page, or closes that page in full-screen mode.
  Future<void> _toggleFullscreen() async {
    if (widget.fullscreen) {
      Navigator.of(context).pop();
      return;
    }
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => VideoConfigInhWidget(
          state: _scope,
          child: const Scaffold(
            backgroundColor: Colors.black,
            body: VideoPlayerWidget(fullscreen: true),
          ),
        ),
      ),
    );
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _showQualities() => showVideoQualitySheet(
    context,
    qualities: _scope.qualities,
    selected: _scope.videoPlaybackDataController.quality,
    onSelected: _scope.changeQuality,
  );

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final fullscreen = widget.fullscreen;
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.5),
      child: SafeArea(
        top: fullscreen,
        bottom: fullscreen,
        child: Stack(
          children: [
            if (!fullscreen) VideoPlayerCloseButton(onPressed: _scope.close),
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                onPressed: _scope.qualities.length < 2 ? null : _showQualities,
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ),
            Center(
              child: ValueListenableBuilder(
                valueListenable: video,
                builder: (context, value, _) => IconButton(
                  iconSize: 56,
                  onPressed: _scope.togglePlay,
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
                valueListenable: video,
                builder: (context, value, _) => Row(
                  children: [
                    Text(
                      formatDuration(value.position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: VideoProgressIndicator(
                        video,
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
                    Text(
                      formatDuration(value.duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _toggleFullscreen,
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
}
