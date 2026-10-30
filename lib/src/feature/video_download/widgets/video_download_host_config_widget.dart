import 'package:flutter/material.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/video_download/controller/download_options_controller.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/data/video_download_repository.dart';

/// Provides [VideoDownloadHostConfigWidgetState] to the whole app.
class VideoDownloadHostConfigInhWidget extends InheritedWidget {
  const VideoDownloadHostConfigInhWidget({required this.state, required super.child, super.key});

  final VideoDownloadHostConfigWidgetState state;

  static VideoDownloadHostConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<VideoDownloadHostConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'VideoDownloadHostConfigInhWidget was not found in the widget tree');
    return (widget! as VideoDownloadHostConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant VideoDownloadHostConfigInhWidget oldWidget) => false;
}

/// Owns the app-wide download: it keeps running while the user moves around the app, so this
/// sits above the navigator and lives as long as the app.
class VideoDownloadHostConfigWidget extends StatefulWidget {
  const VideoDownloadHostConfigWidget({required this.child, super.key});

  final Widget child;

  @override
  State<VideoDownloadHostConfigWidget> createState() => VideoDownloadHostConfigWidgetState();
}

class VideoDownloadHostConfigWidgetState extends State<VideoDownloadHostConfigWidget> {
  late final IVideoDownloadRepository _videoDownloadRepository;
  late final VideoDownloadController videoDownloadController;

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    _videoDownloadRepository = VideoDownloadRepositoryImpl(
      streamsClient: dependencies.youtubeStreamsClient,
      downloader: dependencies.downloader,
      muxer: dependencies.mediaMuxer,
      mediaStore: dependencies.deviceMediaStore,
      database: dependencies.database,
      analytics: dependencies.analytics,
    );
    videoDownloadController = VideoDownloadController(repository: _videoDownloadRepository);
  }

  @override
  void dispose() {
    videoDownloadController.dispose();
    super.dispose();
  }

  /// A controller for the qualities of one video, sharing this host's repository.
  /// The caller owns it and disposes it.
  DownloadOptionsController createDownloadOptionsController() =>
      DownloadOptionsController(repository: _videoDownloadRepository);

  @override
  Widget build(BuildContext context) =>
      VideoDownloadHostConfigInhWidget(state: this, child: widget.child);
}
