import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/widgets/text_widget.dart';

class ChangeQualityVideoPopup extends StatelessWidget {
  const ChangeQualityVideoPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(
      builder: (context, state) {
        var currentState = state.youtubeVideoStateModel;
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 20),
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: currentState.videosWithSound.length,
          itemBuilder: (context, index) {
            debugPrint("length of videos: ${currentState.videosWithSound.length}");
            var video = currentState.videosWithSound[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(
                    onPressed: () {
                      context.read<YoutubeVideoCubit>().pickQualityOfVideo(videoStreamInfo: video);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: TextWidget(
                        text: video.qualityLabel,
                        size: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.9,
                      ),
                    )),
              ],
            );
          },
        );
      },
    );
  }
}