import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/video_download/controller/download_options_controller.dart';
import 'package:youtube/src/feature/video_download/controller/video_download_controller.dart';
import 'package:youtube/src/feature/video_download/models/download_option.dart';
import 'package:youtube/src/feature/video_download/models/download_request.dart';
import 'package:youtube/src/feature/video_download/widgets/mobile/video_download_sheet_widget.dart';

/// Provides [VideoDownloadConfigWidgetState] to the download sheet.
class VideoDownloadConfigInhWidget extends InheritedWidget {
  const VideoDownloadConfigInhWidget({required this.state, required super.child, super.key});

  final VideoDownloadConfigWidgetState state;

  static VideoDownloadConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<VideoDownloadConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'VideoDownloadConfigInhWidget was not found in the widget tree');
    return (widget! as VideoDownloadConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant VideoDownloadConfigInhWidget oldWidget) => false;
}

/// The download sheet: choose sound or video, then a quality and a destination.
class VideoDownloadConfigWidget extends StatefulWidget {
  const VideoDownloadConfigWidget({required this.video, super.key});

  static Future<void> show(BuildContext context, {required VideoItem video}) =>
      showModalBottomSheet<void>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        ),
        builder: (_) => VideoDownloadConfigWidget(video: video),
      );

  final VideoItem video;

  @override
  State<VideoDownloadConfigWidget> createState() => VideoDownloadConfigWidgetState();
}

class VideoDownloadConfigWidgetState extends State<VideoDownloadConfigWidget> {
  late final DownloadOptionsController downloadOptionsController;
  late final VideoDownloadController videoDownloadController;

  VideoItem get video => widget.video;

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    videoDownloadController = dependencies.videoDownloadController;
    downloadOptionsController = DownloadOptionsController(
      repository: dependencies.videoDownloadRepository,
    )..load(video.id);
  }

  @override
  void dispose() {
    downloadOptionsController.dispose();
    super.dispose();
  }

  void reload() => downloadOptionsController.load(video.id);

  void chooseKind(DownloadKind kind) =>
      DependenciesScope.of(context).analytics.downloadType(kind.analyticsName);

  /// Starts downloading [option] to [target]; tells the user when another download is running.
  void start(DownloadOption option, DownloadTarget target) {
    final started = videoDownloadController.start(
      DownloadRequest(video: video, option: option, target: target),
    );
    if (!started) {
      showMessage(context, message: Localization.of(context).downloadAnotherRunning, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) =>
      VideoDownloadConfigInhWidget(state: this, child: const VideoDownloadSheetWidget());
}
