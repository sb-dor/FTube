import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/utils/view_format_helper/view_format_helper.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';

class VideoInformationLoadedWidget extends StatelessWidget {
  const VideoInformationLoadedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      var channel = currentState.video?.snippet?.channel;
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextWidget(
          text: currentState.video?.snippet?.title ?? '-',
          size: 18,
          maxLines: 2,
          overFlow: TextOverflow.ellipsis,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
        const SizedBox(height: 3),
        TextWidget(
          text:
              "${ViewFormatHelper.viewsFormatNumbers(int.tryParse("${currentState.video?.snippet?.statistic?.viewCount}"))} "
              "просмотров",
          color: Colors.grey,
          size: 12,
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    shape: BoxShape.rectangle,
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.5,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: ImageLoaderWidget(
                      url: channel?.channelSnippet?.thumbMedium?.url ?? '',
                      errorImageUrl: 'assets/custom_images/custom_user_image.png',
                    ),
                  )),
              const SizedBox(width: 10),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                      text: TextSpan(children: [
                    // WidgetSpan(
                    //     child: Icon(
                    //   Icons.check_circle,
                    //   color: Colors.red,
                    //   size: 13,
                    // )),
                    // const WidgetSpan(
                    //   child: SizedBox(width: 5),
                    // ),
                    WidgetSpan(
                        child: TextWidget(
                      text: "${channel?.channelSnippet?.title ?? '-'}",
                      color: Colors.grey,
                      size: 15,
                      fontWeight: FontWeight.bold,
                    )),
                    const WidgetSpan(
                      child: SizedBox(width: 10),
                    ),
                    //
                    WidgetSpan(
                        child: TextWidget(
                      text:
                          "${ViewFormatHelper.viewsFormatNumbers(int.tryParse("${currentState.video?.snippet?.channel?.channelSnippet?.channelStatistics?.subscriberCount}"))} ",
                      color: Colors.grey,
                      size: 13,
                      textAlign: TextAlign.start,
                    ))
                  ])),
                ],
              )),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.only(left: 15, right: 15, bottom: 7, top: 7),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    TextWidget(
                      text: "Скачать",
                      color: Colors.white,
                      size: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                    SizedBox(width: 7),
                    Icon(
                      Icons.download,
                      size: 12,
                      color: Colors.white,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ]);
    });
  }
}
