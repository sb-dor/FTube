import 'dart:async';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/features/home_screen/usecases/open_video_screen/open_video_screen.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/utils/duration_helper/duration_helper.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/utils/reusable_global_widgets.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideosLoadedWidget extends StatelessWidget {
  final List<ytv.Video> videoList;
  final bool closeScreenBeforeOpeningAnotherOne;

  const VideosLoadedWidget({
    Key? key,
    required this.videoList,
    this.closeScreenBeforeOpeningAnotherOne = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 30),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: videoList.length,
      itemBuilder: (context, index) {
        var video = videoList[index];
        return _MainVideoWidget(
          video: video,
          closeScreenBeforeOpeningAnotherOne: closeScreenBeforeOpeningAnotherOne,
        );
      },
    );
  }
}

class _MainVideoWidget extends StatefulWidget {
  final ytv.Video video;
  final bool closeScreenBeforeOpeningAnotherOne;

  const _MainVideoWidget({
    super.key,
    required this.video,
    required this.closeScreenBeforeOpeningAnotherOne,
  });

  @override
  State<_MainVideoWidget> createState() => _MainVideoWidgetState();
}

class _MainVideoWidgetState extends State<_MainVideoWidget> {
  // for showing video
  VideoPlayerController? _videoPlayerController;

  // for getting info about videos
  final YoutubeExplode _youtubeExplode = locator<YoutubeExplode>();

  // reusable functions that use in app
  final ReusableGlobalFunctions _globalFunctions = locator<ReusableGlobalFunctions>();

  // temp values for changing ui and "if" statements
  bool _initializingVideoBeforeShowing = false, _videoIsInitializing = false;

  Timer? _timer;

  // if video is playing this variable will change every time in order to show videos current duration
  String? currentVideoGoingDuration;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // whether use clicks video for init or not we have to init controller anyway
    _initEveryController();
  }

  Future<void> _initEveryController() async {
    try {
      // we have to init our controller only that time when it's null
      if (_videoPlayerController == null) {
        // check whether controller is initializing
        if (_videoIsInitializing) return;
        _videoIsInitializing = true;

        // get information about video
        var informationVideo = await _youtubeExplode.videos.streamsClient.getManifest(
          widget.video.videoId,
        );

        // get only those videos which are recommended and will not throw any error in the future
        final videosWithSound = informationVideo.video
            .where((e) =>
                e.size.totalMegaBytes >= 1 &&
                _globalFunctions.checkMp4FromURI(
                  value: e.url.toString(),
                ))
            .toList();

        // get the lowest video one (360p quality)
        VideoStreamInfo streamInfo = videosWithSound.first;

        for (var each in videosWithSound) {
          if (each.size.totalMegaBytes < streamInfo.size.totalMegaBytes) {
            streamInfo = each;
          }
        }

        // init the controller
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(streamInfo.url.toString()),
        );

        // setting false means that we are done with initializing
        _videoIsInitializing = false;
      }
    } catch (e) {
      debugPrint("_initEveryController error is: $e");
      FirebaseCrashlytics.instance.log(e.toString());
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _onPointerDownEvent(PointerDownEvent event) async {
    if ((_timer?.isActive ?? false)) _timer?.cancel();
    // timer checks whether user want to watch temp video or wants to enter to video
    _timer = Timer(const Duration(seconds: 1), () async {
      // just for showing loading before loading video (progress indicator)
      _initializingVideoBeforeShowing = true;
      setState(() {});
      // while user touches the screen on video, check whether video was initialized
      await _initEveryController();
      // if the controller is still not initialized break the code
      if (_videoPlayerController == null) return;
      setState(() {});
      // if the controller is not initialize, initialize it
      if (!(_videoPlayerController?.value.isInitialized ?? false)) {
        await _videoPlayerController?.initialize();
      }
      // if the video is not playing, start to play the video
      if (!(_videoPlayerController?.value.isPlaying ?? false)) {
        await _videoPlayerController?.play();
        await _videoPlayerController?.setVolume(0);
      }

      // set this variable to false saying that initializing was end (in order to remove circular progress indicator)
      _initializingVideoBeforeShowing = false;
      setState(() {});

      // after initializing the video, function starts to listen the video changes,
      // whenever video pauses (not starts to buffer), that means that user changed video on screen.
      // We have to set null to this widget's controller
      _onPointerDownEventListener();
    });
  }

  void _onPointerDownEventListener() {
    _videoPlayerController?.addListener(() async {
      if (!(_videoPlayerController?.value.isPlaying ?? false)) {
        // stop video before setting null
        await _clearController();
      } else {
        currentVideoGoingDuration =
            locator<DurationHelper>().getFromDuration(await _videoPlayerController?.position);
        setState(() {});
      }
    });
  }

  Future<void> _clearController() async {
    // stop video before setting null
    await _videoPlayerController?.pause();
    _videoPlayerController = null;
    currentVideoGoingDuration = null;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await _clearController();
        if (widget.closeScreenBeforeOpeningAnotherOne && context.mounted) Navigator.pop(context);
        if (!context.mounted) return;
        context.read<HistoryBloc>().add(AddOnHistoryEvent(video: widget.video));
        OpenVideoScreen.openVideoScreen(
          context: context,
          videoId: widget.video.videoId ?? '',
          videoThumb:
              (widget.video.thumbnails ?? []).isEmpty ? null : widget.video.thumbnails?.first.url,
        );
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: Stack(
                children: [
                  if ((_videoPlayerController?.value.isInitialized ?? false) &&
                      (_videoPlayerController?.value.isPlaying ?? false))
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),

                        // fitted box and setting video's width and height in sizedbox
                        // is the best way to fit the video
                        child: FittedBox(
                          fit: _videoPlayerController!.value.size.width >=
                                  _videoPlayerController!.value.size.height
                              ? BoxFit.cover
                              : BoxFit.scaleDown,
                          child: SizedBox(
                            width: _videoPlayerController!.value.size.width,
                            height: _videoPlayerController!.value.size.height,
                            child: VideoPlayer(
                              _videoPlayerController!,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ImageLoaderWidget(
                          url: widget.video.thumbnails?.last.url ?? '',
                          errorImageUrl: 'assets/custom_images/custom_user_image.png',
                          boxFit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Positioned(
                      top: 5,
                      left: 10,
                      right: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child:
                                // (video.loadingVideoData)
                                //     ? const TextWidget(
                                //         text: ". . .",
                                //         size: 12,
                                //         fontWeight: FontWeight.bold,
                                //         color: Colors.white,
                                //       )
                                //     :
                                Row(children: [
                              const Icon(
                                Icons.remove_red_eye_outlined,
                                size: 20,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 5),
                              TextWidget(
                                text: widget.video.views ?? '',
                                size: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              )
                            ]),
                          ),
                          IconButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStatePropertyAll(Colors.black.withOpacity(0.2))),
                              onPressed: () {
                                VideoModelDb model = VideoModelDb.fromVideo(widget.video);
                                locator<ReusableGlobalWidgets>().showPlaylistAddingPopup(
                                  context: context,
                                  videoModelDb: model,
                                );
                              },
                              icon: const Icon(
                                Icons.more_horiz,
                                color: Colors.white,
                              ))
                        ],
                      )),
                  Positioned(
                      bottom: 10,
                      right: 10,
                      left: 10,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_initializingVideoBeforeShowing)
                            const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else if ((_videoPlayerController?.value.isInitialized ?? false) &&
                              (_videoPlayerController?.value.isPlaying ?? false))
                            Material(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(50),
                              child: InkWell(
                                onTap: () {
                                  if ((_videoPlayerController?.value.volume ?? 0.0) == 1) {
                                    _videoPlayerController?.setVolume(0.0);
                                  } else {
                                    _videoPlayerController?.setVolume(1.0);
                                  }
                                  setState(() {});
                                },
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: Icon(
                                      _videoPlayerController?.value.volume == 1
                                          ? Icons.volume_down_sharp
                                          : Icons.volume_up_sharp,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          else
                            const SizedBox(),
                          if (currentVideoGoingDuration != null)
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                              decoration: BoxDecoration(
                                  color: Colors.black, borderRadius: BorderRadius.circular(3)),
                              child: TextWidget(
                                text: currentVideoGoingDuration ?? "-",
                                color: Colors.white,
                                size: 10,
                              ),
                            )
                          else
                            Container(
                              padding:
                                  const EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                              decoration: BoxDecoration(
                                  color: Colors.black, borderRadius: BorderRadius.circular(3)),
                              child: TextWidget(
                                text: widget.video.duration ?? "",
                                color: Colors.white,
                                size: 10,
                              ),
                            ),
                        ],
                      )),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: MediaQuery.of(context).size.width / 4.3,
                    right: MediaQuery.of(context).size.width / 4.3,
                    child: Listener(
                      onPointerDown: _onPointerDownEvent,
                      onPointerUp: (v) => _timer?.cancel(),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // if (video.loadingVideoData)
                  //   ShimmerContainer(
                  //       width: 50, height: 50, borderRadius: BorderRadius.circular(50))
                  // else if (video.errorOfLoadingVideoData)
                  //   Container(
                  //       color: Colors.red,
                  //       width: 50,
                  //       height: 50,
                  //       child: const TextWidget(text: "E", color: Colors.red))
                  // else
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: ImageLoaderWidget(
                        url: widget.video.channelThumbnailUrl ?? '',
                        errorImageUrl: 'assets/custom_images/custom_user_image.png',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: widget.video.title ?? '-',
                          size: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                  child: TextWidget(
                                text: widget.video.channelName ?? "-",
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              )),
                              const WidgetSpan(
                                  child: TextWidget(
                                text: "  •  ",
                                size: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              )),
                              WidgetSpan(
                                child: TextWidget(
                                  text: widget.video.publishedDateTime ?? '-',
                                  size: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
