import 'package:flutter/material.dart';
import 'package:youtube/src/feature/download_player/controller/download_player_controller.dart';
import 'package:youtube/src/feature/download_player/data/download_player_repository.dart';
import 'package:youtube/src/feature/download_player/widgets/controllers/download_player_data_controller.dart';
import 'package:youtube/src/feature/download_player/widgets/mobile/download_player_mobile_widget.dart';
import 'package:youtube/src/feature/downloads/models/downloaded_file.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';

/// Provides [DownloadPlayerConfigWidgetState] to the player popup.
class DownloadPlayerConfigInhWidget extends InheritedWidget {
  const DownloadPlayerConfigInhWidget({required this.state, required super.child, super.key});

  final DownloadPlayerConfigWidgetState state;

  static DownloadPlayerConfigWidgetState of(BuildContext context) {
    final widget = context
        .getElementForInheritedWidgetOfExactType<DownloadPlayerConfigInhWidget>()
        ?.widget;
    assert(widget != null, 'DownloadPlayerConfigInhWidget was not found in the widget tree');
    return (widget! as DownloadPlayerConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant DownloadPlayerConfigInhWidget oldWidget) => false;
}

/// Popup that plays one downloaded file: video files with `video_player`, audio files through
/// the app's background audio player. Playback stops when the popup closes.
class DownloadPlayerConfigWidget extends StatefulWidget {
  const DownloadPlayerConfigWidget({required this.file, super.key});

  /// Shows the player for [file]; completes when the popup closes. Tap outside to close.
  static Future<void> show(BuildContext context, {required DownloadedFile file}) =>
      showDialog<void>(
        context: context,
        builder: (context) => DownloadPlayerConfigWidget(file: file),
      );

  final DownloadedFile file;

  @override
  State<DownloadPlayerConfigWidget> createState() => DownloadPlayerConfigWidgetState();
}

class DownloadPlayerConfigWidgetState extends State<DownloadPlayerConfigWidget> {
  late final DownloadPlayerController downloadPlayerController;
  late final DownloadPlayerDataController downloadPlayerDataController;
  late final AppLifecycleListener _lifecycleListener;

  DownloadedFile get file => widget.file;

  @override
  void initState() {
    super.initState();
    final backgroundAudio = DependenciesScope.of(context).backgroundAudio;
    downloadPlayerController = DownloadPlayerController(
      downloadPlayerRepository: file.isVideo
          ? VideoFilePlayerRepository(backgroundAudio: backgroundAudio)
          : AudioFilePlayerRepository(backgroundAudio: backgroundAudio),
    );
    downloadPlayerDataController = DownloadPlayerDataController();
    _lifecycleListener = AppLifecycleListener(
      onPause: downloadPlayerController.appPaused,
      onResume: downloadPlayerController.appResumed,
    );
    open();
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    downloadPlayerController.dispose();
    downloadPlayerDataController.dispose();
    super.dispose();
  }

  void open() => downloadPlayerController.open(file);

  @override
  Widget build(BuildContext context) =>
      DownloadPlayerConfigInhWidget(state: this, child: const DownloadPlayerMobileWidget());
}
