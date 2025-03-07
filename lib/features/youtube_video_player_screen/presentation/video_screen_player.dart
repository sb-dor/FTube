import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/services/audio_background_service.dart';
import 'package:youtube/core/widgets/videos_widgets/videos_error_widget.dart';
import 'package:youtube/core/widgets/videos_widgets/videos_loaded_widget.dart';
import 'package:youtube/core/widgets/videos_widgets/videos_loading_widget.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';
import 'package:youtube/core/widgets/custom_clipper_helper/custom_clipper_helper.dart';
import 'package:youtube/core/widgets/image_loader_widget.dart';
import 'bloc/cubits/similar_videos_cubit/similar_videos_cubit.dart';
import 'bloc/cubits/similar_videos_cubit/similar_videos_states.dart';
import 'bloc/cubits/video_information_cubit/video_information_cubit.dart';
import 'bloc/cubits/video_information_cubit/video_information_states.dart';
import 'widgets/video_info_like_buttons_widgets/video_info_like_button_loaded_widgets.dart';
import 'widgets/video_info_like_buttons_widgets/video_info_like_button_loading_widgets.dart';
import 'widgets/video_informations_widgets/video_information_loaded_widget.dart';
import 'widgets/video_informations_widgets/video_information_loading_widget.dart';
import 'widgets/video_player_widgets/black_with_opacity_background.dart';
import 'widgets/video_player_widgets/last_next_stop_play_widget.dart';
import 'widgets/video_player_widgets/video_dutaion_information.dart';
import 'widgets/video_player_widgets/video_player_widget.dart';
import 'widgets/video_player_widgets/video_settings_button.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String? videoThumb;
  final void Function() showOverlay;
  final BuildContext parentContext;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.showOverlay,
    required this.parentContext,
    this.videoThumb,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  //
  late final ScrollController _scrollController;
  late final YoutubeVideoCubit _youtubeVideoCubit;
  late final VideoInformationCubit _videoInformationCubit;
  late final DraggableScrollableController _scrollableController;
  late AnimationController _animationController;
  late Animation<double> _animation;
  SendPort? sendPort;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.bottom],
    );
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    _scrollController = ScrollController();
    _scrollableController = DraggableScrollableController();
    _youtubeVideoCubit = BlocProvider.of<YoutubeVideoCubit>(context);
    _videoInformationCubit = BlocProvider.of<VideoInformationCubit>(context);
    _youtubeVideoCubit.init(
      url: widget.videoId,
      mixin: this,
      context: context,
      paginating: false,
      videoPicture: widget.videoThumb,
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);

    _scrollController.addListener(() {
      if (_scrollController.offset ==
          _scrollController.position.maxScrollExtent) {
        _youtubeVideoCubit.getSimilarVideos(context: context, paginating: true);
      }
    });
  }

  @override
  void dispose() {
    widget.showOverlay();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _youtubeVideoCubit.dispose();
    _videoInformationCubit.loadingVideoInformationState();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      // debugPrint"AppLife is: detached");
      final audioHandler = JustAudioBackgroundHelper.instance;
      await audioHandler.stopPlayer();
    } else if (state == AppLifecycleState.hidden) {
      // debugPrint"AppLife is: hidden");
    } else if (state == AppLifecycleState.inactive) {
      // debugPrint"AppLife is: inactive");
    } else if (state == AppLifecycleState.paused) {
      // debugPrint"AppLife is: paused");
      // if (defaultTargetPlatform == TargetPlatform.android) {
      //   final bodyForSend = {
      //     "url_for_run": _youtubeVideoCubit.state.youtubeVideoStateModel.videoUrlForOverlayRun,
      //   };
      //   await FlutterOverlayWindow.shareData(jsonEncode(bodyForSend));
      //   await FlutterOverlayWindow.showOverlay(
      //     height: 350,
      //     width: (MediaQuery.of(goRouter.configuration.navigatorKey.currentContext!).size.width * 2)
      //         .toInt(),
      //     enableDrag: true,
      //     visibility: NotificationVisibility.visibilitySecret,
      //     overlayTitle: "Running on background",
      //   );
      // }

      // this code should work when:
      //
      // 1) "mediaItem" for background audio is not null,
      // 2) media was loaded once for background
      // 3) and video is playing
      //
      // otherwise we will not load audio for background
      if (_youtubeVideoCubit
                  .state
                  .youtubeVideoStateModel
                  .mediaItemForRunningInBackground !=
              null &&
          !_youtubeVideoCubit
              .state
              .youtubeVideoStateModel
              .loadedMusicForBackground &&
          (_youtubeVideoCubit
                  .state
                  .youtubeVideoStateModel
                  .playerController
                  ?.value
                  .isPlaying ??
              false)) {
        _youtubeVideoCubit.loadedMusicForBackground(value: true);

        final audioService = JustAudioBackgroundHelper.instance;

        audioService.setNewAudioSources(
          items: [
            _youtubeVideoCubit
                .state
                .youtubeVideoStateModel
                .mediaItemForRunningInBackground!,
          ],
          duration:
              _youtubeVideoCubit
                  .state
                  .youtubeVideoStateModel
                  .lastVideoDurationForMediaBackground!,
        );
      }
    } else if (state == AppLifecycleState.resumed) {
      final audioHandler = JustAudioBackgroundHelper.instance;
      await _youtubeVideoCubit.seekToTheDurationPosition(
        audioHandler.lastSavedDuration,
      );
      await audioHandler.stopPlayer();
      _youtubeVideoCubit.loadedMusicForBackground(value: false);
      // if (defaultTargetPlatform == TargetPlatform.android) {
      //   await FlutterOverlayWindow.closeOverlay();
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final youtubeStates = context.watch<YoutubeVideoCubit>().state;
        final videoInformationStates =
            context.watch<VideoInformationCubit>().state;
        final similarVideoCubit = context.watch<SimilarVideosCubit>();

        final youtubeStateModel = youtubeStates.youtubeVideoStateModel;

        return DraggableScrollableSheet(
          controller: _scrollableController,
          initialChildSize: 1,
          expand: false,
          snap: true,
          builder: (context, controller) {
            return SafeArea(
              child: Scaffold(
                body: Column(
                  children: [
                    if (youtubeStateModel.loadingVideo ||
                        youtubeStateModel.playerController == null)
                      Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.315,
                        child: Stack(
                          children: [
                            if (youtubeStateModel.videoPicture != null)
                              Positioned.fill(
                                child: SizedBox.expand(
                                  child: ImageLoaderWidget(
                                    url: youtubeStateModel.videoPicture ?? '',
                                    errorImageUrl:
                                        "assets/custom_images/error_image.png",
                                    boxFit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            const Positioned.fill(
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.315,
                        child: Stack(
                          children: [
                            const VideoPlayerWidget(),
                            const BlackWithOpacityBackground(),
                            if (youtubeStateModel.clickedUpOnVideo)
                              VideoDurationInformation(
                                animationController: _animationController,
                                animation: _animation,
                              ),
                            if (youtubeStateModel.clickedUpOnVideo)
                              LastNextStopPlayWidget(
                                animationController: _animationController,
                                animation: _animation,
                              ),
                            if (youtubeStateModel.clickedUpOnVideo)
                              const VideoSettingsButton(),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            bottom: MediaQuery.of(context).size.height / 2,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.white,
                            ),
                          ),
                          Positioned.fill(
                            child: ListView(
                              controller: _scrollController,
                              children: [
                                Stack(
                                  children: [
                                    if (videoInformationStates
                                        is! ErrorVideoInformationState)
                                      CustomerClipperWithShadow(
                                        clipper: _Clipper(),
                                        blurRadius: 1,
                                        child: Container(
                                          // change bottom to 80 if you want to show bottom subscription buttons
                                          padding: const EdgeInsets.only(
                                            bottom: 50,
                                          ),
                                          color: Colors.white,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 10,
                                              right: 10,
                                            ),
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 10),
                                                //
                                                if (videoInformationStates
                                                    is LoadingVideoInformationState)
                                                  const VideoInformationLoadingWidget()
                                                else if (videoInformationStates
                                                    is ErrorVideoInformationState)
                                                  const Text("Error")
                                                else
                                                  const VideoInformationLoadedWidget(),

                                                //
                                                const SizedBox(height: 10),
                                                if (videoInformationStates
                                                    is LoadingVideoInformationState)
                                                  const VideoInfoLikeButtonLoadingWidgets()
                                                else if (videoInformationStates
                                                    is ErrorVideoInformationState)
                                                  const Text("Error")
                                                else
                                                  const VideoInfoLikeButtonLoadedWidget(),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    // if (videoInformationStates is LoadingVideoInformationState)
                                    //   const VideoInfoSubsButtonsLoadingWidget()
                                    // else if (videoInformationStates is ErrorVideoInformationState)
                                    //   const SizedBox()
                                    // else
                                    //   const VideoInfoSubsButtonsLoadedWidget(),
                                  ],
                                ),
                                // const SizedBox(height: 10),
                                if (similarVideoCubit.state
                                    is LoadingSimilarVideosState)
                                  const Padding(
                                    padding: EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: VideosLoadingWidget(),
                                  )
                                else if (similarVideoCubit.state
                                    is ErrorSimilarVideosState)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: VideosErrorWidget(
                                      onTap:
                                          () => context
                                              .read<YoutubeVideoCubit>()
                                              .getSimilarVideos(
                                                context: context,
                                                paginating: false,
                                              ),
                                    ),
                                  )
                                else if (similarVideoCubit.state
                                        is LoadedSimilarVideosState &&
                                    similarVideoCubit
                                        .state
                                        .similarVideoStateModel
                                        .similarVideos
                                        .isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: VideosLoadedWidget(
                                      closeScreenBeforeOpeningAnotherOne: true,
                                      videoList:
                                          similarVideoCubit
                                              .state
                                              .similarVideoStateModel
                                              .similarVideos,
                                      parentContext: widget.parentContext,
                                    ),
                                  )
                                else
                                  const SizedBox(),
                                const SizedBox(height: 10),
                                if (similarVideoCubit
                                        .state
                                        .similarVideoStateModel
                                        .hasMore &&
                                    similarVideoCubit.state
                                        is! ErrorSimilarVideosState)
                                  const Column(
                                    children: [
                                      SizedBox(
                                        width: 15,
                                        height: 15,
                                        child: CircularProgressIndicator(
                                          color: Colors.red,
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                // VideoInformationLoadedWidget(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _Clipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.moveTo(0, 0);

    path.lineTo(0, size.height - 50);

    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 50,
    );

    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
