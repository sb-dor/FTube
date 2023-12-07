import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/animations/fade_animation.dart';
import 'package:youtube/pages/youtube_video_player_page/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_page/cubit/youtube_video_states.dart';

class BlackWithOpacityBackground extends StatelessWidget {
  const BlackWithOpacityBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      return Positioned.fill(
          child: FadeAnimation(
        beginValue: currentState.clickedUpOnVideo ? 0 : 1,
        endValue: currentState.clickedUpOnVideo ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        child: GestureDetector(
            onTap: () => context.read<YoutubeVideoCubit>().clickOnVideo(),
            child: Container(color: Colors.black.withOpacity(0.5))),
      ));
    });
  }
}
