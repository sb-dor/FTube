import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/widget/network_image_widget.dart';
import 'package:youtube/src/feature/video/controller/video_playback_controller.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_player_close_button.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_player_controls_widget.dart';
import 'package:youtube/src/feature/video/widgets/video_config_widget.dart';

/// The player area with its controls. [fullscreen] is the landscape page variant.
class VideoPlayerWidget extends StatefulWidget {
  const VideoPlayerWidget({super.key, this.fullscreen = false});

  final bool fullscreen;

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late final _scope = VideoConfigInhWidget.of(context);
  late final _controller = _scope.videoPlaybackController;
  late final _dataController = _scope.videoPlaybackDataController;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: Colors.black,
    child: StateConsumer<VideoPlaybackController, VideoPlaybackState>(
      controller: _controller,
      builder: (context, state, _) => switch (state) {
        VideoPlayback$ErrorState() => Center(
          child: Text(
            Localization.of(context).videoPlaybackError,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        VideoPlayback$CompletedState(:final video) => ListenableBuilder(
          listenable: _dataController,
          builder: (context, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _dataController.toggleControls,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: video.value.aspectRatio,
                    child: VideoPlayer(video),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _dataController.controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: IgnorePointer(
                    ignoring: !_dataController.controlsVisible,
                    child: VideoPlayerControlsWidget(video: video, fullscreen: widget.fullscreen),
                  ),
                ),
              ],
            ),
          ),
        ),
        VideoPlayback$InitialState() || VideoPlayback$InProgressState() => Stack(
          fit: StackFit.expand,
          children: [
            if (_scope.widget.opened?.thumbnail case final thumbnail?)
              NetworkImageWidget(url: thumbnail),
            const Center(child: CircularProgressIndicator(color: AppColors.accent)),
            if (!widget.fullscreen) VideoPlayerCloseButton(onPressed: _scope.close),
          ],
        ),
      },
    ),
  );
}
