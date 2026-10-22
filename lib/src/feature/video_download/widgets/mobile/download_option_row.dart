import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';

/// One quality in the download sheet with its two destinations, or the progress of the
/// download that is running for it.
class DownloadOptionRow extends StatelessWidget {
  const DownloadOptionRow({
    required this.option,
    required this.recommended,
    required this.downloadState,
    required this.videoId,
    required this.onDownload,
    required this.onCancel,
    super.key,
  });

  final DownloadOption option;
  final bool recommended;
  final VideoDownloadState downloadState;
  final String videoId;
  final void Function(DownloadOption option, DownloadTarget target) onDownload;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final megabytes = (option.sizeBytes / (1024 * 1024)).toStringAsFixed(2);
    final quality = option.kind == DownloadKind.audio
        ? l10n.downloadBitrate(option.bitrateKbps)
        : option.qualityLabel ?? '';
    final note = switch (option.kind) {
      DownloadKind.audio when recommended => l10n.downloadRecommendedAudio,
      DownloadKind.video when option.isFast => l10n.downloadFastVideo,
      _ => null,
    };
    final running =
        downloadState is VideoDownload$InProgressState &&
        downloadState.activeRequest?.video.id == videoId &&
        downloadState.activeRequest?.option == option;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.downloadQuality(quality), style: const TextStyle(fontSize: 16)),
                Text(
                  '${l10n.downloadSize(megabytes)} · ${option.extension.toUpperCase()}',
                  style: const TextStyle(fontSize: 14),
                ),
                if (note case final note?)
                  Text(note, style: const TextStyle(color: AppColors.accent, fontSize: 13)),
              ],
            ),
          ),
          if (running)
            _RunningIndicator(
              state: downloadState as VideoDownload$InProgressState,
              onCancel: onCancel,
            )
          else ...[
            IconButton(
              tooltip: option.kind == DownloadKind.audio
                  ? l10n.downloadAudioToDevice
                  : l10n.downloadVideoToGallery,
              onPressed: () => onDownload(option, DownloadTarget.device),
              icon: option.kind == DownloadKind.audio
                  ? const Icon(Icons.download)
                  : Image.asset('assets/download_icons/gallery_save.png', width: 26, height: 26),
            ),
            IconButton(
              tooltip: option.kind == DownloadKind.audio
                  ? l10n.downloadAudioToApp
                  : l10n.downloadVideoToApp,
              onPressed: () => onDownload(option, DownloadTarget.appStorage),
              icon: Image.asset('assets/download_icons/in_app_download.png', width: 26, height: 26),
            ),
          ],
        ],
      ),
    );
  }
}

class _RunningIndicator extends StatelessWidget {
  const _RunningIndicator({required this.state, required this.onCancel});

  final VideoDownload$InProgressState state;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 44,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CircularProgressIndicator(
          value: state.progress.fraction,
          strokeWidth: 3,
          color: AppColors.accent,
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).cancelButtonLabel,
          onPressed: onCancel,
          icon: const Icon(Icons.close, size: 18),
        ),
      ],
    ),
  );
}
