import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/models/download_request.dart';
import 'package:youtube/src/feature/video_download/widgets/video_download_config_widget.dart';

/// Black "Download" pill on the video screen. Shows the running download of this video, or a
/// small cancellable chip when another video is downloading.
class VideoDownloadButton extends StatefulWidget {
  const VideoDownloadButton({required this.video, super.key});

  final VideoItem video;

  @override
  State<VideoDownloadButton> createState() => _VideoDownloadButtonState();
}

class _VideoDownloadButtonState extends State<VideoDownloadButton> {
  late final _controller = DependenciesScope.of(context).videoDownloadController;

  Future<void> _confirmCancel() async {
    final l10n = Localization.of(context);
    final stop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.downloadCancelTitle),
        content: Text(l10n.downloadCancelContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.downloadContinue),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.downloadCancelConfirm),
          ),
        ],
      ),
    );
    if (stop ?? false) _controller.cancel();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final l10n = Localization.of(context);
      final state = _controller.state;
      final running = state is VideoDownload$InProgressState ? state : null;
      final isThisVideo = running?.request.video.id == widget.video.id;
      final label = switch (running?.progress.phase) {
        _ when !isThisVideo => l10n.downloadButton,
        DownloadPhase.downloading when (running?.progress.receivedBytes ?? 0) == 0 =>
          l10n.downloadPreparing,
        DownloadPhase.downloading => l10n.downloadDownloading,
        DownloadPhase.processing => l10n.downloadProcessing,
        DownloadPhase.saving => l10n.downloadSaving,
        null => l10n.downloadButton,
      };
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (running != null && !isThisVideo)
            ActionChip(
              avatar: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  value: running.progress.fraction,
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
              label: const Icon(Icons.close, size: 16),
              onPressed: _confirmCancel,
            ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            onPressed: isThisVideo
                ? _confirmCancel
                : () => VideoDownloadConfigWidget.show(context, video: widget.video),
            iconAlignment: IconAlignment.end,
            icon: isThisVideo
                ? SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      value: running?.progress.fraction,
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.download, size: 18),
            label: Text(label),
          ),
        ],
      );
    },
  );
}
