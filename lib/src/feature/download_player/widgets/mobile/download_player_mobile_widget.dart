import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:text_marquee/text_marquee.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/download_player/controller/download_player_controller.dart';
import 'package:youtube/src/feature/download_player/widgets/download_player_config_widget.dart';
import 'package:youtube/src/feature/download_player/widgets/mobile/download_player_controls_widget.dart';

/// The player card centered over a transparent page; tapping outside the card closes it.
class DownloadPlayerMobileWidget extends StatefulWidget {
  const DownloadPlayerMobileWidget({super.key});

  @override
  State<DownloadPlayerMobileWidget> createState() => _DownloadPlayerMobileWidgetState();
}

class _DownloadPlayerMobileWidgetState extends State<DownloadPlayerMobileWidget> {
  late final _scope = DownloadPlayerConfigInhWidget.of(context);
  late final _controller = _scope.downloadPlayerController;
  late final _dataController = _scope.downloadPlayerDataController;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.pop(context),
      child: Center(
        child: GestureDetector(
          // Taps on the card must not close the popup.
          onTap: () {},
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: StateConsumer<DownloadPlayerController, DownloadPlayerState>(
              controller: _controller,
              builder: (context, state, _) => switch (state) {
                DownloadPlayer$InitialState() || DownloadPlayer$InProgressState() => const SizedBox(
                  height: 140,
                  child: Center(child: CircularProgressIndicator()),
                ),
                DownloadPlayer$ErrorState() => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.grey, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        _scope.file.exists
                            ? Localization.of(context).downloadPlayerError
                            : Localization.of(context).downloadsFileMissing,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                DownloadPlayer$CompletedState() => ListenableBuilder(
                  listenable: _dataController,
                  builder: (context, _) => _content(state),
                ),
              },
            ),
          ),
        ),
      ),
    ),
  );

  Widget _content(DownloadPlayer$CompletedState state) {
    final video = state.video;
    final showVideo = video != null && _dataController.isVideoVisible;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        if (showVideo)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _VideoPictureWidget(video: video),
          )
        else
          SizedBox(
            width: double.infinity,
            height: 20,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: TextMarquee(
                _scope.file.title.isEmpty ? '-' : _scope.file.title,
                duration: const Duration(seconds: 5),
              ),
            ),
          ),
        const SizedBox(height: 10),
        DownloadPlayerControlsWidget(
          state: state,
          dragPosition: _dataController.dragPosition,
          onDragStart: _controller.seekStart,
          onDrag: _dataController.drag,
          onDragEnd: (position) {
            _dataController.endDrag();
            _controller.seekEnd(position);
          },
          onTogglePlay: _controller.togglePlay,
        ),
        if (video != null)
          IconButton(
            tooltip: _dataController.isVideoVisible
                ? Localization.of(context).downloadPlayerHideVideo
                : Localization.of(context).downloadPlayerShowVideo,
            onPressed: _dataController.toggleVideo,
            icon: Icon(
              _dataController.isVideoVisible
                  ? Icons.highlight_remove
                  : Icons.slow_motion_video_outlined,
            ),
          ),
      ],
    );
  }
}

/// The video picture with rounded corners: landscape fills the card width, portrait is limited
/// to most of the screen height.
class _VideoPictureWidget extends StatelessWidget {
  const _VideoPictureWidget({required this.video});

  final VideoPlayerController video;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = video.value.isInitialized ? video.value.aspectRatio : 16 / 9;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(borderRadius: BorderRadius.circular(10), child: VideoPlayer(video)),
      ),
    );
  }
}
