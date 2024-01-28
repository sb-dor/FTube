import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_states.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      return Positioned.fill(
        child: Container(
          color: Colors.black,
          child: Center(
            child: state is InitialYoutubeVideoState
                ? AspectRatio(
                    aspectRatio: currentState.playerController!.value.aspectRatio,
                    child: GestureDetector(
                      onTap: () => context.read<YoutubeVideoCubit>().clickOnVideo(),
                      child: VideoPlayer(
                        currentState.playerController!,
                      ),
                    ),
                  )
                : const Text("Error occurred", style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    });
  }
}
