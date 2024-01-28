import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';

class LastNextStopPlayWidget extends StatelessWidget {
  const LastNextStopPlayWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      return Positioned.fill(
          child: AnimatedBuilder(
              animation: currentState.playPauseController,
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
                        context.read<YoutubeVideoCubit>().stopVideo();
                        if (currentState.stopVideo) {
                          currentState.playPauseController.forward();
                        } else {
                          currentState.playPauseController.reverse();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: AnimatedIcon(
                          icon: AnimatedIcons.pause_play,
                          progress: currentState.playPauseAnimation,
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
              }));
    });
  }
}
