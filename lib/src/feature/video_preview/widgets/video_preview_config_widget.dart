import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/duration_format.dart';
import 'package:youtube/src/common/widget/video_card_widget.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/video_preview/controller/video_preview_controller.dart';
import 'package:youtube/src/feature/video_preview/data/video_preview_repository.dart';
import 'package:youtube/src/feature/video_preview/widgets/controllers/video_preview_coordinator.dart';

/// Wraps a card thumbnail: holding the centre of it for a second plays a muted preview.
class VideoPreviewConfigWidget extends StatefulWidget {
  const VideoPreviewConfigWidget({required this.video, required this.child, super.key});

  /// Share of the width left free on each side of the hold area (the hint overlay uses it).
  static const double sideInsetFactor = 1 / 4.3;

  final VideoItem video;
  final Widget child;

  @override
  State<VideoPreviewConfigWidget> createState() => _VideoPreviewConfigWidgetState();
}

class _VideoPreviewConfigWidgetState extends State<VideoPreviewConfigWidget>
    with WidgetsBindingObserver {
  late final VideoPreviewController _controller;
  late final VideoPreviewCoordinator _coordinator;
  VideoPlayerController? _player;
  Timer? _holdTimer;
  Offset? _downAt;

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    _coordinator = dependencies.videoPreviewCoordinator..addListener(_onCoordinator);
    _controller = VideoPreviewController(
      repository: VideoPreviewRepositoryImpl(streamsClient: dependencies.youtubeStreamsClient),
    )..addListener(_onPreviewState);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _holdTimer?.cancel();
    _coordinator
      ..removeListener(_onCoordinator)
      ..release(this);
    _controller
      ..removeListener(_onPreviewState)
      ..dispose();
    _player?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _stop();
  }

  void _onCoordinator() {
    if (!identical(_coordinator.active, this)) _stop(release: false);
  }

  Future<void> _onPreviewState() async {
    final state = _controller.state;
    if (state is! VideoPreview$ReadyState || !identical(_coordinator.active, this)) return;
    final player = VideoPlayerController.networkUrl(
      state.source.url,
      httpHeaders: state.source.headers,
    );
    _player = player;
    try {
      await player.initialize();
      await player.setVolume(0);
      if (!identical(_player, player)) return;
      await player.play();
      player.addListener(_onPlayer);
    } on Object {
      _stop();
    }
    if (mounted) setState(() {});
  }

  void _onPlayer() {
    final value = _player?.value;
    if (value == null) return;
    if (value.isCompleted) _stop();
  }

  void _start() {
    _coordinator.claim(this);
    _controller.load(widget.video.id);
    setState(() {});
  }

  void _stop({bool release = true}) {
    _holdTimer?.cancel();
    final player = _player;
    _player = null;
    player?.dispose();
    if (_controller.state is! VideoPreview$IdleState) _controller.stop();
    if (release) _coordinator.release(this);
    if (mounted) setState(() {});
  }

  void _onPointerDown(PointerDownEvent event) {
    _downAt = event.position;
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 1), _start);
  }

  void _onPointerMove(PointerMoveEvent event) {
    final start = _downAt;
    if (start != null && (event.position - start).distance > 12) _holdTimer?.cancel();
  }

  void _onPointerEnd(PointerEvent _) => _holdTimer?.cancel();

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.sizeOf(context).width * VideoPreviewConfigWidget.sideInsetFactor;
    final player = _player;
    final loading =
        _controller.state is VideoPreview$InProgressState ||
        (player != null && !player.value.isInitialized);
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
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerEnd,
            onPointerCancel: _onPointerEnd,
          ),
        ),
        if (loading)
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
            child: ValueListenableBuilder(
              valueListenable: player,
              builder: (context, value, _) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RoundButton(icon: Icons.play_disabled, onTap: _stop),
                  const SizedBox(height: 4),
                  _RoundButton(
                    icon: value.volume == 0 ? Icons.volume_up_sharp : Icons.volume_off_sharp,
                    onTap: () => player.setVolume(value.volume == 0 ? 1 : 0),
                  ),
                  const SizedBox(height: 4),
                  DurationBadge(text: formatDuration(value.position)),
                ],
              ),
            ),
          ),
      ],
    );
  }
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
