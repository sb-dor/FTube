import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/feature/mini_player/models/mini_player_session.dart';
import 'package:youtube/src/feature/mini_player/widgets/mini_player_config_widget.dart';

/// Draggable 250×150 player. Tap shows play/pause and expand; X closes.
class MiniPlayerWidget extends StatefulWidget {
  const MiniPlayerWidget({required this.session, super.key});

  final MiniPlayerSession session;

  @override
  State<MiniPlayerWidget> createState() => _MiniPlayerWidgetState();
}

class _MiniPlayerWidgetState extends State<MiniPlayerWidget> {
  static const _size = Size(250, 150);
  late final _scope = MiniPlayerConfigInhWidget.maybeOf(context)!;
  late final VideoPlayerController _player;
  Offset _offset = const Offset(20, 40);
  bool _controlsVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _player = VideoPlayerController.networkUrl(
      widget.session.url,
      httpHeaders: widget.session.headers,
    );
    _start();
  }

  Future<void> _start() async {
    _scope.positionReader = () => _player.value.position;
    try {
      await _player.initialize();
      await _player.seekTo(widget.session.position);
      await _player.play();
    } on Object {
      // The stream link may have expired; the box stays with a play button.
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (_scope.positionReader != null) _scope.positionReader = null;
    _player.dispose();
    super.dispose();
  }

  void _toggleControls() {
    _hideTimer?.cancel();
    setState(() => _controlsVisible = !_controlsVisible);
    if (_controlsVisible) {
      _hideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final left = _offset.dx.clamp(0.0, screen.width - _size.width);
    final top = _offset.dy.clamp(padding.top, screen.height - _size.height - padding.bottom);
    return Positioned(
      left: left,
      top: top,
      width: _size.width,
      height: _size.height,
      child: GestureDetector(
        onPanUpdate: (details) => setState(() => _offset = Offset(left, top) + details.delta),
        onTap: _toggleControls,
        child: Material(
          color: Colors.black,
          elevation: 8,
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          child: ValueListenableBuilder(
            valueListenable: _player,
            builder: (context, value, _) => Stack(
              fit: StackFit.expand,
              children: [
                if (value.isInitialized)
                  FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox.fromSize(size: value.size, child: VideoPlayer(_player)),
                  )
                else
                  const Center(child: CircularProgressIndicator(color: Colors.white)),
                if (_controlsVisible || (value.isInitialized && !value.isPlaying))
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: value.isPlaying ? _player.pause : _player.play,
                          icon: Icon(
                            value.isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                        IconButton(
                          onPressed: _scope.expand,
                          icon: const Icon(Icons.open_in_full, color: Colors.white, size: 28),
                        ),
                      ],
                    ),
                  ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    onPressed: _scope.close,
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
