import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube/blocs_and_cubits/home_screen_bloc/main_home_screen_bloc.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/utils/reusable_global_widgets.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/shimmer_container.dart';
import 'package:youtube/widgets/text_widget.dart';

class HomeScreenVideosLoadedWidget extends StatelessWidget {
  const HomeScreenVideosLoadedWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final mainHomeScreenState = context.watch<MainHomeScreenBloc>().state;

      var mainHomeScreenStateModel = mainHomeScreenState.homeScreenStateModel;
      return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 30),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: mainHomeScreenStateModel.videos.length,
          itemBuilder: (context, index) {
            var video = mainHomeScreenStateModel.videos[index];
            return GestureDetector(
              onTap: () => ReusableGlobalWidgets.instance
                  .showVideoScreen(context: context, videoId: video.id?.videoID ?? ''),
              child: Container(
                color: Colors.transparent,
                child: Column(children: [
                  SizedBox(
                    height: (video.snippet?.thumbnailHigh?.height ?? 180) / 2,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: ImageLoaderWidget(
                              url: video.snippet?.thumbnailHigh?.url ?? '',
                              errorImageUrl: 'assets/custom_images/custom_user_image.png',
                              boxFit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                            top: 5,
                            left: 10,
                            right: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding:
                                      const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: (video.snippet?.loadingStatistics ?? true)
                                      ? TextWidget(
                                          text: ". . .",
                                          size: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        )
                                      : Row(children: [
                                          const Icon(
                                            Icons.remove_red_eye_outlined,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 5),
                                          TextWidget(
                                            text: (video.snippet?.loadingStatistics ?? true)
                                                ? ""
                                                : ReusableGlobalFunctions.instance
                                                    .viewsFormatNumbers(int.tryParse(
                                                        "${video.snippet?.statistic?.viewCount}")),
                                            size: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          )
                                        ]),
                                ),
                                IconButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStatePropertyAll(
                                            Colors.black.withOpacity(0.2))),
                                    onPressed: () => [],
                                    icon: const Icon(
                                      Icons.more_horiz,
                                      color: Colors.white,
                                    ))
                              ],
                            ))
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if ((video.snippet?.loadingChannel ?? false))
                        ShimmerContainer(
                            width: 50, height: 50, borderRadius: BorderRadius.circular(50))
                      else if ((video.snippet?.errorChannel ?? false))
                        Container(
                            color: Colors.red,
                            width: 50,
                            height: 50,
                            child: const TextWidget(text: "E", color: Colors.red))
                      else
                        ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: SizedBox(
                              width: 50,
                              height: 50,
                              child: ImageLoaderWidget(
                                  url: video.snippet?.channel?.channelSnippet?.thumbMedium?.url ??
                                      '',
                                  errorImageUrl: 'assets/custom_images/custom_user_image.png')),
                        ),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            TextWidget(
                              text: video.snippet?.title ?? '-',
                              size: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                            TextWidget(
                              text: video.snippet?.channelTitle ?? '-',
                              size: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ]))
                    ]),
                  )
                ]),
              ),
            );
          });
    });
  }
}
