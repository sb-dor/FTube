import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/duration_format.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/mini_player/models/mini_player_session.dart';
import 'package:youtube/src/feature/mini_player/widgets/mini_player_config_widget.dart';
import 'package:youtube/src/feature/video/controller/related_videos_controller.dart';
import 'package:youtube/src/feature/video/controller/video_bookmark_controller.dart';
import 'package:youtube/src/feature/video/controller/video_controller.dart';
import 'package:youtube/src/feature/video/controller/video_like_controller.dart';
import 'package:youtube/src/feature/video/controller/video_streams_controller.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';
import 'package:youtube/src/feature/video/data/video_repository.dart';
import 'package:youtube/src/feature/video/widgets/controllers/video_playback_controller.dart';
import 'package:youtube/src/feature/video/widgets/mobile/video_mobile_widget.dart';

/// Provides [VideoConfigWidgetState] to the video screen.
class VideoConfigInhWidget extends InheritedWidget {
  const VideoConfigInhWidget({required this.state, required super.child, super.key});

  final VideoConfigWidgetState state;

  static VideoConfigWidgetState of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<VideoConfigInhWidget>()?.widget;
    assert(widget != null, 'VideoConfigInhWidget was not found in the widget tree');
    return (widget! as VideoConfigInhWidget).state;
  }

  @override
  bool updateShouldNotify(covariant VideoConfigInhWidget oldWidget) => false;
}

/// The video screen: player, information, actions and similar videos, in a full-height sheet
/// that is dragged down to close. Closing continues the video in the mini player.
class VideoConfigWidget extends StatefulWidget {
  const VideoConfigWidget({required this.videoId, super.key, this.opened, this.startAt});

  /// Opens [video] tapped in a list.
  static Future<void> open(BuildContext context, {required VideoItem video, Duration? startAt}) =>
      _present(context, videoId: video.id, opened: video, startAt: startAt);

  /// Opens a video from a link.
  static Future<void> openById(BuildContext context, {required String videoId}) =>
      _present(context, videoId: videoId);

  static Future<void> _present(
    BuildContext context, {
    required String videoId,
    VideoItem? opened,
    Duration? startAt,
  }) {
    DependenciesScope.of(context).videoPreviewCoordinator.stopAll();
    final miniPlayer = MiniPlayerConfigWidget.close(context);
    final resumeAt = startAt ?? (miniPlayer?.video.id == videoId ? miniPlayer!.position : null);
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.white,
      builder: (_) => VideoConfigWidget(videoId: videoId, opened: opened, startAt: resumeAt),
    );
  }

  final String videoId;

  /// The list item that was tapped; null when opened from a link.
  final VideoItem? opened;
  final Duration? startAt;

  @override
  State<VideoConfigWidget> createState() => VideoConfigWidgetState();
}

class VideoConfigWidgetState extends State<VideoConfigWidget> {
  late final VideoController videoController;
  late final VideoStreamsController videoStreamsController;
  late final RelatedVideosController relatedVideosController;
  late final VideoLikeController videoLikeController;
  late final VideoBookmarkController videoBookmarkController;
  late final VideoPlaybackController videoPlaybackController;
  late final AppLifecycleListener _lifecycle;
  late final NavigatorState _rootNavigator;
  MiniPlayerConfigWidgetState? _miniPlayer;

  /// Set when another video replaces this sheet; the mini player is not shown then.
  bool _replaced = false;

  String get videoId => widget.videoId;

  /// The video with everything known about it so far (list item merged with details).
  VideoItem get video {
    final opened = widget.opened;
    final state = videoController.state;
    if (state is! Video$CompletedState) return opened ?? VideoItem(id: videoId, title: '');
    final details = state.details;
    return VideoItem(
      id: videoId,
      title: details.title.isNotEmpty ? details.title : opened?.title ?? '',
      channelName: details.channelName ?? opened?.channelName,
      channelId: details.channelId ?? opened?.channelId,
      channelAvatarUrl: details.channelAvatarUrl ?? opened?.channelAvatarUrl,
      thumbnailUrl: opened?.thumbnailUrl,
      viewsText: opened?.viewsText ?? details.viewsText,
      durationText: opened?.durationText,
      publishedText: opened?.publishedText ?? details.publishedText,
      isLive: opened?.isLive ?? false,
    );
  }

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    _rootNavigator = Navigator.of(context, rootNavigator: true);
    _miniPlayer = MiniPlayerConfigWidget.maybeOfState(context);
    final repository = VideoRepositoryImpl(
      youtubeClient: dependencies.youtubeClient,
      youtubeExplode: dependencies.youtubeExplode,
      streamsClient: dependencies.youtubeStreamsClient,
      database: dependencies.database,
    );
    final libraryRepository = VideoLibraryRepositoryImpl(database: dependencies.database);
    videoPlaybackController = VideoPlaybackController(
      backgroundAudio: dependencies.backgroundAudio,
    );
    videoController = VideoController(repository: repository);
    videoStreamsController = VideoStreamsController(repository: repository);
    relatedVideosController = RelatedVideosController(repository: repository);
    videoLikeController = VideoLikeController(repository: libraryRepository);
    videoBookmarkController = VideoBookmarkController(repository: libraryRepository);
    // Listeners and loads start only once every controller exists: a state change can be
    // delivered synchronously.
    videoController
      ..addListener(_onVideo)
      ..load(videoId, opened: widget.opened);
    videoStreamsController
      ..addListener(_onStreams)
      ..load(videoId);
    videoLikeController.watch(videoId);
    videoBookmarkController.watch(videoId);
    _lifecycle = AppLifecycleListener(
      onPause: () => videoPlaybackController.moveToBackground(_mediaItem()),
      onResume: videoPlaybackController.returnFromBackground,
    );
    // Full-screen look: the status bar is hidden while the video screen is open.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _lifecycle.dispose();
    final url = videoPlaybackController.url;
    if (!_replaced && url != null && videoPlaybackController.isReady) {
      _miniPlayer?.miniPlayerDataController.show(
        MiniPlayerSession(
          video: video,
          url: url,
          headers: videoPlaybackController.headers,
          position: videoPlaybackController.position,
        ),
      );
    }
    videoController
      ..removeListener(_onVideo)
      ..dispose();
    videoStreamsController
      ..removeListener(_onStreams)
      ..dispose();
    relatedVideosController.dispose();
    videoLikeController.dispose();
    videoBookmarkController.dispose();
    videoPlaybackController.dispose();
    super.dispose();
  }

  void _onVideo() {
    switch (videoController.state) {
      case Video$CompletedState(:final details):
        relatedVideosController.show(details.related);
      case Video$ErrorState(:final error):
        relatedVideosController.fail(error);
      default:
    }
  }

  void _onStreams() {
    if (videoStreamsController.state case VideoStreams$CompletedState(:final streams)) {
      videoPlaybackController.open(streams, startAt: widget.startAt ?? Duration.zero);
    }
  }

  MediaItem _mediaItem() {
    final video = this.video;
    return MediaItem(
      id: videoId,
      title: video.title,
      artist: video.channelName,
      artUri: Uri.parse(video.thumbnail),
      duration: switch (secondsFromDurationText(video.durationText)) {
        final seconds? => Duration(seconds: seconds),
        null => videoPlaybackController.player?.value.duration,
      },
    );
  }

  void retry() {
    videoController.load(videoId, opened: widget.opened);
    if (videoStreamsController.state is VideoStreams$ErrorState)
      videoStreamsController.load(videoId);
  }

  /// Closes the screen (the video continues in the mini player).
  void close() => Navigator.of(context).maybePop();

  /// Replaces this screen with [related].
  void openRelated(VideoItem related) {
    _replaced = true;
    videoPlaybackController.pause();
    _rootNavigator.pop();
    unawaited(VideoConfigWidget.open(_rootNavigator.context, video: related));
  }

  @override
  Widget build(BuildContext context) =>
      VideoConfigInhWidget(state: this, child: const VideoMobileWidget());
}
