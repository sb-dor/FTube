import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';

class VideoPlayerWidget extends StatelessWidget {
  const VideoPlayerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      // debugPrint("width is : ${currentState.playerController?.value.size.width}");
      // debugPrint("height is : ${currentState.playerController?.value.size.height}");
      return Positioned.fill(
        child: Container(
          color: Colors.black,
          child: Center(
            child: state is InitialYoutubeVideoState
                ? GestureDetector(
                    onTap: () => context.read<YoutubeVideoCubit>().clickOnVideo(),
                    child: SizedBox.expand(
                      child: FittedBox(
                        fit: currentState.playerController!.value.size.width >=
                                currentState.playerController!.value.size.height
                            ? BoxFit.cover
                            : BoxFit.scaleDown,
                        child: SizedBox(
                          width: currentState.playerController!.value.size.width,
                          height: currentState.playerController!.value.size.height,
                          child: VideoPlayer(
                            currentState.playerController!,
                          ),
                        ),
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
