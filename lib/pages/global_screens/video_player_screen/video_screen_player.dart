import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube/animations/fade_animation.dart';
import 'package:youtube/blocs_and_cubits/youtube_video_cubit/youtube_video_cubit.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with SingleTickerProviderStateMixin {
  late final YoutubeVideoCubit _youtubeVideoCubit;
  late final DraggableScrollableController _scrollableController;
  late AnimationController _playPauseController;
  late Animation<double> _playPauseAnimation;

  @override
  void initState() {
    super.initState();
    _playPauseController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _playPauseAnimation = Tween<double>(begin: 0, end: 1).animate(_playPauseController);
    _scrollableController = DraggableScrollableController();
    _youtubeVideoCubit = BlocProvider.of<YoutubeVideoCubit>(context);
    _youtubeVideoCubit.init(url: widget.videoId);
  }

  @override
  void dispose() {
    _youtubeVideoCubit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final youtubeStates = context.watch<YoutubeVideoCubit>().state;

      var youtubeStateModel = youtubeStates.youtubeVideoStateModel;

      return DraggableScrollableSheet(
          controller: _scrollableController,
          initialChildSize: 0.96,
          expand: false,
          snap: true,
          builder: (context, controller) {
            return SafeArea(
              child: Scaffold(
                body: Column(children: [
                  // PodVideoPlayer(
                  //   matchVideoAspectRatioToFrame: true,
                  //   controller: youtubeStates.playerController,
                  //   alwaysShowProgressBar: false,
                  // ),
                  if (youtubeStateModel.loadingVideo)
                    Container(
                        color: Colors.black,
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.red,
                          ),
                        ))
                  else
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: GestureDetector(
                                onTap: () => _youtubeVideoCubit.clickOnVideo(),
                                child: VideoPlayer(
                                  youtubeStateModel.playerController,

                                ),
                              ),
                            ),
                            Positioned.fill(
                                child: FadeAnimation(
                              beginValue: youtubeStateModel.clickedUpOnVideo ? 0 : 1,
                              endValue: youtubeStateModel.clickedUpOnVideo ? 1 : 0,
                              duration: const Duration(milliseconds: 250),
                              child: GestureDetector(
                                  onTap: () => _youtubeVideoCubit.clickOnVideo(),
                                  child: Container(color: Colors.black.withOpacity(0.5))),
                            )),
                            if (youtubeStateModel.clickedUpOnVideo)
                              Positioned(
                                  right: 10,
                                  left: 18,
                                  bottom: 0,
                                  child: FadeAnimation(
                                    duration: const Duration(milliseconds: 250),
                                    child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          TextWidget(
                                            text: youtubeStateModel.runningTime,
                                            size: 13,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          Row(children: [
                                            TextWidget(
                                              text: ReusableGlobalFunctions.instance
                                                  .getFromDuration(youtubeStateModel
                                                      .playerController.value.duration),
                                              size: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            IconButton(
                                                style: ButtonStyle(
                                                    overlayColor: MaterialStatePropertyAll(
                                                        Colors.white.withOpacity(0.3))),
                                                onPressed: () => [],
                                                icon: const Icon(
                                                  Icons.fullscreen,
                                                  size: 28,
                                                  color: Colors.white,
                                                ))
                                          ])
                                        ]),
                                  )),
                            if (youtubeStateModel.clickedUpOnVideo)
                              Positioned.fill(
                                  child: AnimatedBuilder(
                                      animation: _playPauseController,
                                      builder: (context, child) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                                onPressed: () => [],
                                                icon: const Icon(
                                                  CupertinoIcons.backward_end_fill,
                                                  color: Colors.white,
                                                )),
                                            GestureDetector(
                                              onTap: () {
                                                _youtubeVideoCubit.stopVideo();
                                                if (youtubeStateModel.stopVideo) {
                                                  _playPauseController.forward();
                                                } else {
                                                  _playPauseController.reverse();
                                                }
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                child: AnimatedIcon(
                                                  icon: AnimatedIcons.pause_play,
                                                  progress: _playPauseAnimation,
                                                  color: Colors.white,
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                                onPressed: () => [],
                                                icon: const Icon(
                                                  CupertinoIcons.forward_end_fill,
                                                  color: Colors.white,
                                                )),
                                          ],
                                        );
                                      }))
                          ],
                        )),
                  Expanded(child: ListView(children: []))
                ]),
              ),
            );
          });
    });
  }
}
