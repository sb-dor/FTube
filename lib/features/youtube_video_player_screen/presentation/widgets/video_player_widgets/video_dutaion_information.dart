import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/animations/fade_animation.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/utils/duration_helper/duration_helper.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideoDurationInformation extends StatelessWidget {
  const VideoDurationInformation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      return Positioned(
          right: 10,
          left: 18,
          bottom: 5, // remove here when you uncomment the fullscreen button
          child: FadeAnimation(
            duration: const Duration(milliseconds: 250),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              TextWidget(
                text: currentState.runningTime,
                size: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(
                  child: SizedBox(
                height: 15,
                child: VideoProgressIndicator(
                  currentState.playerController!,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                      playedColor: Colors.green, bufferedColor: Colors.white60),
                ),
              )),
              const SizedBox(width: 10),
              Row(children: [
                TextWidget(
                  text:
                      DurationHelper.getFromDuration(currentState.playerController!.value.duration),
                  size: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                // IconButton(
                //     style: ButtonStyle(
                //         overlayColor: MaterialStatePropertyAll(Colors.white.withOpacity(0.3))),
                //     onPressed: () => [],
                //     icon: const Icon(
                //       Icons.fullscreen,
                //       size: 28,
                //       color: Colors.white,
                //     ))
              ])
            ]),
          ));
    });
  }
}
