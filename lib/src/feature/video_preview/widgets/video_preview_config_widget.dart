import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/controller/video_preview_coordinator.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/video_preview/controller/video_preview_controller.dart';
import 'package:youtube/src/feature/video_preview/data/video_preview_repository.dart';
import 'package:youtube/src/feature/video_preview/widgets/mobile/video_preview_mobile_widget.dart';

/// Provides [VideoPreviewConfigWidgetState] to the preview of one card.
class VideoPreviewConfigInhWidget extends InheritedWidget {
  const VideoPreviewConfigInhWidget({required this.state, required super.child, super.key});

  final VideoPreviewConfigWidgetState state;

  static VideoPreviewConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<VideoPreviewConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'VideoPreviewConfigInhWidget was not found in the widget tree');
    return (widget! as VideoPreviewConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant VideoPreviewConfigInhWidget oldWidget) => false;
}

/// Wraps a card thumbnail: holding the centre of it for a second plays a muted preview.
class VideoPreviewConfigWidget extends StatefulWidget {
  const VideoPreviewConfigWidget({required this.video, required this.child, super.key});

  /// Share of the width left free on each side of the hold area (the hint overlay uses it).
  static const double sideInsetFactor = 1 / 4.3;

  final VideoItem video;
  final Widget child;

  @override
  State<VideoPreviewConfigWidget> createState() => VideoPreviewConfigWidgetState();
}

class VideoPreviewConfigWidgetState extends State<VideoPreviewConfigWidget>
    with WidgetsBindingObserver {
  late final VideoPreviewController videoPreviewController;
  late final VideoPreviewCoordinator _coordinator;
  VideoPlayerController? _player;
  Timer? _holdTimer;
  Offset? _downAt;

  /// The preview playing (or starting); null when there is none.
  VideoPlayerController? get player => _player;

  /// The stream is being resolved or the player is starting.
  bool get isLoading =>
      videoPreviewController.state is VideoPreview$InProgressState ||
      (_player != null && !_player!.value.isInitialized);

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    _coordinator = dependencies.videoPreviewCoordinator..addListener(_onCoordinator);
    videoPreviewController = VideoPreviewController(
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
    videoPreviewController
      ..removeListener(_onPreviewState)
      ..dispose();
    _player?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) stop();
  }

  void _onCoordinator() {
    if (!identical(_coordinator.active, this)) stop(release: false);
  }

  Future<void> _onPreviewState() async {
    final state = videoPreviewController.state;
    if (state is! VideoPreview$CompletedState || !identical(_coordinator.active, this)) return;
    // A new hold while a preview plays: it restarts with the new stream.
    _player?.dispose();
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
      // A player replaced meanwhile fails because it was released; only the current one stops.
      if (identical(_player, player)) stop();
    }
    if (mounted) setState(() {});
  }

  void _onPlayer() {
    final value = _player?.value;
    if (value == null) return;
    if (value.isCompleted) stop();
  }

  void _start() {
    _coordinator.claim(this);
    videoPreviewController.load(widget.video.id);
    setState(() {});
  }

  /// Stops the preview; [release] lets another card's preview play.
  void stop({bool release = true}) {
    _holdTimer?.cancel();
    final player = _player;
    _player = null;
    player?.dispose();
    if (videoPreviewController.state is! VideoPreview$InitialState) videoPreviewController.stop();
    if (release) _coordinator.release(this);
    if (mounted) setState(() {});
  }

  /// A finger went down on the hold area: the preview starts after a second.
  void onPointerDown(PointerDownEvent event) {
    _downAt = event.position;
    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: 1), _start);
  }

  /// Scrolling is not holding.
  void onPointerMove(PointerMoveEvent event) {
    final start = _downAt;
    if (start != null && (event.position - start).distance > 12) _holdTimer?.cancel();
  }

  void onPointerEnd(PointerEvent _) => _holdTimer?.cancel();

  /// The mobile widget is rebuilt with this state (it is not const).
  @override
  Widget build(BuildContext context) => VideoPreviewConfigInhWidget(
    state: this,
    child: VideoPreviewMobileWidget(child: widget.child),
  );
}
