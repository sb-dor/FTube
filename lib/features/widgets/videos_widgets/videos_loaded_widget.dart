import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/video_db/video_model_db/video_model_db.dart';
import 'package:youtube/features/home_screen/usecases/open_video_screen/open_video_screen.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/utils/reusable_global_widgets.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/shimmer_container.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';
import 'package:youtube/youtube_data_api/models/video.dart' as ytv;

class VideosLoadedWidget extends StatelessWidget {
  final List<ytv.Video> videoList;
  final bool closeScreenBeforeOpeningAnotherOne;

  const VideosLoadedWidget({
    Key? key,
    required this.videoList,
    this.closeScreenBeforeOpeningAnotherOne = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (context, index) => const SizedBox(height: 30),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: videoList.length,
        itemBuilder: (context, index) {
          var video = videoList[index];
          return GestureDetector(
            onTap: () {
              if (closeScreenBeforeOpeningAnotherOne) Navigator.pop(context);
              context.read<HistoryBloc>().add(AddOnHistoryEvent(video: video));
              OpenVideoScreen.openVideoScreen(
                context: context,
                videoId: video.videoId ?? '',
                videoThumb: (video.thumbnails ?? []).isEmpty ? null : video.thumbnails?.first.url,
              );
            },
            child: Container(
              color: Colors.transparent,
              child: Column(children: [
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ImageLoaderWidget(
                            url: video.thumbnails?.last.url ?? '',
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
                                child:
                                    // (video.loadingVideoData)
                                    //     ? const TextWidget(
                                    //         text: ". . .",
                                    //         size: 12,
                                    //         fontWeight: FontWeight.bold,
                                    //         color: Colors.white,
                                    //       )
                                    //     :
                                    Row(children: [
                                  const Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 5),
                                  TextWidget(
                                    text: video.views ?? '',
                                    size: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  )
                                ]),
                              ),
                              IconButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStatePropertyAll(Colors.black.withOpacity(0.2))),
                                  onPressed: () {
                                    VideoModelDb model = VideoModelDb.fromVideo(video);
                                    locator<ReusableGlobalWidgets>().showPlaylistAddingPopup(
                                      context: context,
                                      videoModelDb: model,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.more_horiz,
                                    color: Colors.white,
                                  ))
                            ],
                          )),
                      Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, right: 10, top: 1, bottom: 1),
                            decoration: BoxDecoration(
                                color: Colors.black, borderRadius: BorderRadius.circular(3)),
                            child: TextWidget(
                              text: video.duration ?? "",
                              color: Colors.white,
                              size: 10,
                            ),
                          ))
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                IntrinsicHeight(
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // if (video.loadingVideoData)
                    //   ShimmerContainer(
                    //       width: 50, height: 50, borderRadius: BorderRadius.circular(50))
                    // else if (video.errorOfLoadingVideoData)
                    //   Container(
                    //       color: Colors.red,
                    //       width: 50,
                    //       height: 50,
                    //       child: const TextWidget(text: "E", color: Colors.red))
                    // else
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade400,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: ImageLoaderWidget(
                          url: video.channelThumbnailUrl ?? '',
                          errorImageUrl: 'assets/custom_images/custom_user_image.png',
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          TextWidget(
                            text: video.title ?? '-',
                            size: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                          RichText(
                              text: TextSpan(children: [
                            WidgetSpan(
                                child: TextWidget(
                              text: video.channelName ?? "-",
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            )),
                            const WidgetSpan(
                                child: TextWidget(
                              text: "  •  ",
                              size: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            )),
                            WidgetSpan(
                                child: TextWidget(
                              text: video.publishedDateTime ?? '-',
                              size: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ))
                          ]))
                        ]))
                  ]),
                )
              ]),
            ),
          );
        });
  }
}
