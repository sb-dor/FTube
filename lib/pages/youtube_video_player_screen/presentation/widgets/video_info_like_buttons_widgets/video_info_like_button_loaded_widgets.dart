import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/utils/view_format_helper/view_format_helper.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideoInfoLikeButtonLoadedWidget extends StatelessWidget {
  const VideoInfoLikeButtonLoadedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                        child: Icon(
                      FontAwesomeIcons.thumbsUp,
                      weight: 0.5,
                      color: Colors.grey,
                      size: 20,
                    ))),
                TextWidget(
                  text: ViewFormatHelper.viewsFormatNumbers(int.tryParse(""
                      "${currentState.video?.snippet?.statistic?.likeCount}")),
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  size: 12,
                  letterSpacing: 0.9,
                  textAlign: TextAlign.center,
                )
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                        child: Icon(
                      FontAwesomeIcons.thumbsDown,
                      weight: 0.5,
                      color: Colors.grey,
                      size: 20,
                    ))),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                        child: Icon(
                      FontAwesomeIcons.share,
                      weight: 0.5,
                      color: Colors.grey,
                      size: 20,
                    ))),
                const TextWidget(
                  text: "Поделиться",
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  size: 12,
                  letterSpacing: 0.9,
                  textAlign: TextAlign.center,
                )
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.all(10),
                    child: const Center(
                        child: Icon(
                      FontAwesomeIcons.bookmark,
                      weight: 0.5,
                      color: Colors.grey,
                      size: 20,
                    ))),
                const TextWidget(
                  text: "В избранное",
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                  size: 12,
                  letterSpacing: 0.9,
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ]);
    });
  }
}
