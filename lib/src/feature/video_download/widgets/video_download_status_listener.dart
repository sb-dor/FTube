import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/data/device_media_store.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';

/// Announces finished and failed downloads wherever the user is in the app, then clears them.
class VideoDownloadStatusListener extends StatefulWidget {
  const VideoDownloadStatusListener({required this.messengerKey, required this.child, super.key});

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<VideoDownloadStatusListener> createState() => _VideoDownloadStatusListenerState();
}

class _VideoDownloadStatusListenerState extends State<VideoDownloadStatusListener> {
  late final _controller = DependenciesScope.of(context).videoDownloadController;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final state = _controller.state;
    final request = state.activeRequest;
    if (request == null || state.isDownloading) return;
    final l10n = Localization.of(context);
    final title = request.video.title;
    final (message, isError) = switch (state) {
      VideoDownload$ErrorState(error: MediaPermissionDeniedException()) => (
        l10n.downloadPermissionDenied,
        true,
      ),
      VideoDownload$ErrorState() => (l10n.downloadFailed(title), true),
      _ => switch ((request.target, request.option.kind)) {
        (DownloadTarget.appStorage, _) => (l10n.downloadSavedToApp(title), false),
        (DownloadTarget.device, DownloadKind.video) => (l10n.downloadSavedToGallery(title), false),
        (DownloadTarget.device, DownloadKind.audio) => (
          l10n.downloadSavedToDownloads(title),
          false,
        ),
      },
    };
    widget.messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        ),
      );
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
