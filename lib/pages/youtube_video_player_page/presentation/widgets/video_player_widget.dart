import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pod_player/pod_player.dart';
import 'package:youtube/pages/youtube_video_player_page/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_page/cubit/youtube_video_states.dart';

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
                : Text("Error occurred", style: TextStyle(color: Colors.white)),
          ),
        ),
      );
    });
  }
}
