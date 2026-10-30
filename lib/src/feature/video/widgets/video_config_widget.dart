import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube/src/common/audio/background_audio.dart';
import 'package:youtube/src/common/model/video_item.dart';
import 'package:youtube/src/common/utils/duration_format.dart';
import 'package:youtube/src/feature/initialization/widgets/dependencies_scope.dart';
import 'package:youtube/src/feature/mini_player/models/mini_player_session.dart';
import 'package:youtube/src/feature/mini_player/models/visible_video_screen.dart';
import 'package:youtube/src/feature/mini_player/widgets/mini_player_config_widget.dart';
import 'package:youtube/src/feature/video/controller/related_videos_controller.dart';
import 'package:youtube/src/feature/video/controller/video_bookmark_controller.dart';
import 'package:youtube/src/feature/video/controller/video_controller.dart';
import 'package:youtube/src/feature/video/controller/video_like_controller.dart';
import 'package:youtube/src/feature/video/controller/video_like_toggle_controller.dart';
import 'package:youtube/src/feature/video/controller/video_playback_controller.dart';
import 'package:youtube/src/feature/video/controller/video_streams_controller.dart';
import 'package:youtube/src/feature/video/data/video_library_repository.dart';
import 'package:youtube/src/feature/video/data/video_playback_repository.dart';
import 'package:youtube/src/feature/video/data/video_repository.dart';
import 'package:youtube/src/feature/video/models/video_item_converter.dart';
import 'package:youtube/src/feature/video/models/video_streams.dart';
import 'package:youtube/src/feature/video/widgets/controllers/video_playback_data_controller.dart';
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
    final navigator = Navigator.of(context, rootNavigator: true);
    final miniPlayer = MiniPlayerConfigWidget.maybeOfState(context);
    final current = miniPlayer?.videoScreen;
    // A link to the video already on screen keeps it playing.
    if (current != null && current.videoId == videoId && startAt == null) return Future.value();
    DependenciesScope.of(context).videoPreviewCoordinator.stopAll();
    final session = miniPlayer?.close();
    final resumeAt = startAt ?? (session?.video.id == videoId ? session!.position : null);
    // Only one video screen at a time: another one would leave its video playing underneath,
    // and closing the new one would move it to the mini player over that screen.
    current?.closeForReplacement();
    return showModalBottomSheet<void>(
      context: navigator.context,
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
  late final VideoLikeToggleController videoLikeToggleController;
  late final VideoBookmarkController videoBookmarkController;
  late final VideoPlaybackController videoPlaybackController;
  late final VideoPlaybackDataController videoPlaybackDataController;
  late final AppLifecycleListener _lifecycle;
  late final NavigatorState _rootNavigator;
  MiniPlayerConfigWidgetState? _miniPlayer;

  /// Removes this screen from the mini player scope as the video screen on display.
  VoidCallback? _unregisterScreen;

  /// Set when another video replaces this sheet; the mini player is not shown then.
  bool _replaced = false;

  String get videoId => widget.videoId;

  /// The video with everything known about it so far (list item merged with details).
  VideoItem get video => switch (videoController.state) {
    Video$CompletedState(:final details) => VideoItemConverter(
      opened: widget.opened,
    ).convert(details),
    _ => widget.opened ?? VideoItem(id: videoId, title: ''),
  };

  /// Qualities the video can be played in, lowest first.
  List<PlayableStream> get qualities => switch (videoStreamsController.state) {
    VideoStreams$CompletedState(:final streams) => streams.playable,
    _ => const [],
  };

  @override
  void initState() {
    super.initState();
    final dependencies = DependenciesScope.of(context);
    _rootNavigator = Navigator.of(context, rootNavigator: true);
    _miniPlayer = MiniPlayerConfigWidget.maybeOfState(context);
    _unregisterScreen = _miniPlayer?.registerVideoScreen(
      VisibleVideoScreen(videoId: videoId, closeForReplacement: _closeForReplacement),
    );
    final repository = VideoRepositoryImpl(
      youtubeClient: dependencies.youtubeClient,
      youtubeExplode: dependencies.youtubeExplode,
      streamsClient: dependencies.youtubeStreamsClient,
      database: dependencies.database,
    );
    final libraryRepository = VideoLibraryRepositoryImpl(database: dependencies.database);
    videoPlaybackController = VideoPlaybackController(
      videoPlaybackRepository: VideoPlaybackRepositoryImpl(
        backgroundAudio: dependencies.backgroundAudio,
      ),
    );
    videoPlaybackDataController = VideoPlaybackDataController();
    videoController = VideoController(repository: repository);
    videoStreamsController = VideoStreamsController(repository: repository);
    relatedVideosController = RelatedVideosController(repository: repository);
    videoLikeController = VideoLikeController(videoLibraryRepository: libraryRepository);
    videoLikeToggleController = VideoLikeToggleController(
      videoLibraryRepository: libraryRepository,
    );
    videoBookmarkController = VideoBookmarkController(videoLibraryRepository: libraryRepository);
    // Listeners and loads start only once every controller exists: a state change can be
    // delivered synchronously.
    videoPlaybackController.addListener(_onPlayback);
    videoController
      ..addListener(_onVideo)
      ..load(videoId, opened: widget.opened);
    videoStreamsController
      ..addListener(_onStreams)
      ..load(videoId);
    videoLikeController.watch(videoId);
    videoBookmarkController.watch(videoId);
    _lifecycle = AppLifecycleListener(onPause: _onAppPaused, onResume: _onAppResumed);
    // Full-screen look: the status bar is hidden while the video screen is open.
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom]);
  }

  @override
  void dispose() {
    _unregisterScreen?.call();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _lifecycle.dispose();
    if (videoPlaybackController.state
        case VideoPlayback$CompletedState(video: final player, :final source) when !_replaced) {
      _miniPlayer?.miniPlayerDataController.show(
        MiniPlayerSession(
          video: video,
          url: source.url,
          headers: source.headers,
          position: player.value.position,
        ),
      );
    }
    videoController
      ..removeListener(_onVideo)
      ..dispose();
    videoStreamsController
      ..removeListener(_onStreams)
      ..dispose();
    videoPlaybackController
      ..removeListener(_onPlayback)
      ..dispose();
    relatedVideosController.dispose();
    videoLikeController.dispose();
    videoLikeToggleController.dispose();
    videoBookmarkController.dispose();
    videoPlaybackDataController.dispose();
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
      videoPlaybackDataController.selectQuality(streams.initial);
      videoPlaybackController.open(
        streams.initialSources,
        startAt: widget.startAt ?? Duration.zero,
      );
    }
  }

  void _onPlayback() {
    if (videoPlaybackController.state case VideoPlayback$CompletedState(:final isPlaying)) {
      videoPlaybackDataController.setPlaying(isPlaying);
    }
  }

  void _onAppPaused() => videoPlaybackController.appPaused(
    item: _mediaItem(),
    audio: switch (videoStreamsController.state) {
      VideoStreams$CompletedState(:final streams) => streams.audio,
      _ => null,
    },
  );

  void _onAppResumed() => videoPlaybackController.appResumed();

  MediaItem _mediaItem() {
    final video = this.video;
    return MediaItem(
      id: videoId,
      title: video.title,
      artist: video.channelName,
      artUri: Uri.parse(video.thumbnail),
      duration: switch (secondsFromDurationText(video.durationText)) {
        final seconds? => Duration(seconds: seconds),
        null => switch (videoPlaybackController.state) {
          VideoPlayback$CompletedState(:final video) => video.value.duration,
          _ => null,
        },
      },
    );
  }

  void retry() {
    videoController.load(videoId, opened: widget.opened);
    if (videoStreamsController.state is VideoStreams$ErrorState)
      videoStreamsController.load(videoId);
  }

  /// Plays or pauses the video and shows the controls.
  void togglePlay() {
    videoPlaybackController.togglePlay();
    videoPlaybackDataController.showControls();
  }

  /// Switches to [quality] and continues from the current position.
  void changeQuality(PlayableStream quality) {
    if (quality.url == videoPlaybackDataController.quality?.url) return;
    videoPlaybackDataController.selectQuality(quality);
    videoPlaybackController.switchSources(quality.sources);
  }

  /// Likes or unlikes the video, once whether it is liked is known.
  void toggleLike() {
    if (videoLikeController.state case VideoLike$CompletedState(:final liked)) {
      videoLikeToggleController.setLiked(video, liked: !liked);
    }
  }

  /// Closes the screen (the video continues in the mini player).
  void close() => Navigator.of(context).maybePop();

  /// Replaces this screen with [related].
  void openRelated(VideoItem related) =>
      unawaited(VideoConfigWidget.open(_rootNavigator.context, video: related));

  /// Closes this screen, and any sheet over it, without moving the video to the mini player.
  void _closeForReplacement() {
    _replaced = true;
    videoPlaybackController.pause();
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    _rootNavigator
      ..popUntil((r) => r == route)
      ..pop();
  }

  @override
  Widget build(BuildContext context) =>
      VideoConfigInhWidget(state: this, child: const VideoMobileWidget());
}
