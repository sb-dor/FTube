import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/download_player/controller/download_player_controller.dart';

/// Seek bar, current / total time and the play-pause button.
class DownloadPlayerControlsWidget extends StatelessWidget {
  const DownloadPlayerControlsWidget({
    required this.state,
    required this.dragPosition,
    required this.onDragStart,
    required this.onDrag,
    required this.onDragEnd,
    required this.onTogglePlay,
    super.key,
  });

  final DownloadPlayer$CompletedState state;

  /// The thumb position while the user drags it; null otherwise.
  final Duration? dragPosition;
  final VoidCallback onDragStart;
  final ValueChanged<Duration> onDrag;
  final ValueChanged<Duration> onDragEnd;
  final VoidCallback onTogglePlay;

  static String _format(Duration duration) {
    String two(int value) => value.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return hours > 0 ? '$hours:${two(minutes)}:${two(seconds)}' : '${two(minutes)}:${two(seconds)}';
  }

  static Duration _toDuration(Object? value) =>
      Duration(milliseconds: ((value as num? ?? 0) * 1000).round());

  @override
  Widget build(BuildContext context) {
    final localization = Localization.of(context);
    final total = state.duration.inMilliseconds / 1000;
    final max = math.max(total, 1).toDouble();
    final position = dragPosition ?? state.position;
    final value = (position.inMilliseconds / 1000).clamp(0, max).toDouble();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SfSlider(
          max: max,
          value: value,
          activeColor: AppColors.accent,
          onChangeStart: (_) => onDragStart(),
          onChanged: (value) => onDrag(_toDuration(value)),
          onChangeEnd: (value) => onDragEnd(_toDuration(value)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(position)),
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                tooltip: state.isPlaying
                    ? localization.downloadPlayerPause
                    : localization.downloadPlayerPlay,
                onPressed: onTogglePlay,
                icon: Icon(state.isPlaying ? Icons.pause : Icons.play_arrow, size: 35),
              ),
              Text(_format(state.duration)),
            ],
          ),
        ),
      ],
    );
  }
}
