import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/feature/video_preview/widgets/mobile/video_preview_controls_widget.dart';
import 'package:youtube/src/feature/video_preview/widgets/video_preview_config_widget.dart';

/// The card thumbnail ([child]) with the hold area over its centre and, while previewing, the
/// muted video with its controls on top.
class VideoPreviewMobileWidget extends StatefulWidget {
  const VideoPreviewMobileWidget({required this.child, super.key});

  final Widget child;

  @override
  State<VideoPreviewMobileWidget> createState() => _VideoPreviewMobileWidgetState();
}

class _VideoPreviewMobileWidgetState extends State<VideoPreviewMobileWidget> {
  late final _scope = VideoPreviewConfigInhWidget.of(context);

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.sizeOf(context).width * VideoPreviewConfigWidget.sideInsetFactor;
    final player = _scope.player;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (player != null && player.value.isInitialized)
          FittedBox(
            fit: player.value.aspectRatio >= 1 ? BoxFit.cover : BoxFit.contain,
            child: SizedBox.fromSize(size: player.value.size, child: VideoPlayer(player)),
          ),
        Positioned(
          top: 0,
          bottom: 0,
          left: inset,
          right: inset,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _scope.onPointerDown,
            onPointerMove: _scope.onPointerMove,
            onPointerUp: _scope.onPointerEnd,
            onPointerCancel: _scope.onPointerEnd,
          ),
        ),
        if (_scope.isLoading)
          const Positioned(
            left: 10,
            bottom: 10,
            child: SizedBox.square(
              dimension: 15,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
          )
        else if (player != null)
          Positioned(
            left: 10,
            bottom: 10,
            child: VideoPreviewControlsWidget(player: player, onStop: _scope.stop),
          ),
      ],
    );
  }
}
