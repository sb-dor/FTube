import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/animations/fade_animation.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';

class BlackWithOpacityBackground extends StatelessWidget {
  const BlackWithOpacityBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(
      builder: (context, state) {
        final currentState = state.youtubeVideoStateModel;
        return Positioned.fill(
          child: FadeAnimation(
            beginValue: currentState.clickedUpOnVideo ? 0 : 1,
            endValue: currentState.clickedUpOnVideo ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: GestureDetector(
              onTap: () => context.read<YoutubeVideoCubit>().clickOnVideo(),
              child: Container(
                color: Colors.black.withValues(alpha: 
                  0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
