import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube/features/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/widgets/video_player_widgets/black_with_opacity_background.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/widgets/video_player_widgets/last_next_stop_play_widget.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/widgets/video_player_widgets/video_dutaion_information.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/widgets/video_player_widgets/video_player_widget.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/widgets/video_player_widgets/video_settings_button.dart';

class VideoFullScreenWidget extends StatefulWidget {
  const VideoFullScreenWidget({super.key});

  @override
  State<VideoFullScreenWidget> createState() => _VideoFullScreenWidgetState();
}

class _VideoFullScreenWidgetState extends State<VideoFullScreenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);


    final youTubeVideoCubit = BlocProvider.of<YoutubeVideoCubit>(context).state;
    if ((youTubeVideoCubit.youtubeVideoStateModel.playerController?.value.isPlaying ?? false)) {
      _animationController.reset();
    } else {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final youtubeVideoCubit = context.watch<YoutubeVideoCubit>();

        // data

        final youtubeVideoStateModel = youtubeVideoCubit.state.youtubeVideoStateModel;

        return Scaffold(
          body: RotatedBox(
            quarterTurns: 1,
            child: Container(
              color: Colors.amber,
              width: MediaQuery.of(context).size.height,
              height: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  const VideoPlayerWidget(),
                  const BlackWithOpacityBackground(),
                  if (youtubeVideoStateModel.clickedUpOnVideo)
                    VideoDurationInformation(
                      fullScreen: false,
                      animationController: _animationController,
                      animation: _animation,
                    ),
                  if (youtubeVideoStateModel.clickedUpOnVideo)
                    LastNextStopPlayWidget(
                      animation: _animation,
                      animationController: _animationController,
                    ),
                  if (youtubeVideoStateModel.clickedUpOnVideo)
                    const VideoSettingsButton(fromFullScreen: true),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
