import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/cubits/video_downloading_cubit/video_downloading_states.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_cubit.dart';
import 'package:youtube/pages/youtube_video_player_screen/cubit/youtube_video_states.dart';
import 'package:youtube/pages/youtube_video_player_screen/domain/entities/dowloading_type.dart';
import 'package:youtube/utils/enums.dart';
import 'package:youtube/widgets/text_widget.dart';

class DownloadingVideoPopupWidget extends StatefulWidget {
  const DownloadingVideoPopupWidget({Key? key}) : super(key: key);

  @override
  State<DownloadingVideoPopupWidget> createState() => _DownloadingVideoPopupWidgetState();
}

class _DownloadingVideoPopupWidgetState extends State<DownloadingVideoPopupWidget> {
  late List<Widget> _screens;
  late PageController _pageController;
  double _position = 130;

  @override
  void initState() {
    // TODO: implement initState
    _pageController = PageController();

    super.initState();
    _screens = [
      _SelectDownloadingTypeScreen(pageController: _pageController),
      _VideosDownloadingInformation(pageController: _pageController),
    ];
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _screens.length,
          itemBuilder: (context, index) {
            if (_pageController.hasClients &&
                _pageController.position.hasPixels &&
                _pageController.position.haveDimensions) {
              return AnimatedBuilder(
                  animation: _pageController,
                  builder: (context, child) {
                    _position = MediaQuery.of(context).size.height *
                        ((_pageController.page ?? 0.0) + 1) *
                        0.22;
                    return Column(
                      children: [
                        Expanded(
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context
                                    .read<YoutubeVideoCubit>()
                                    .clearTypeOfDownloadingVideoOnPopup();
                              },
                              child: Container(color: Colors.transparent)),
                        ),
                        Container(
                          height: _position,
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                              )),
                          child: _screens[index],
                        ),
                      ],
                    );
                  });
            } else {
              return Container(height: 130);
            }
          },
        ),
      );
    });
  }
}

class _SelectDownloadingTypeScreen extends StatelessWidget {
  final PageController pageController;

  const _SelectDownloadingTypeScreen({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(builder: (context, state) {
      var currentState = state.youtubeVideoStateModel;
      return Column(
        children: [
          const Spacer(),
          Container(
            height: 130,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
                children: DownloadingType.types
                    .map((e) => Expanded(
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                context.read<YoutubeVideoCubit>().clickTypeOfDownloadingVideo(e);
                                pageController.animateToPage(
                                    ((pageController.page ?? 0) + 1).toInt(),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 175),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: currentState.downloadingType?.id == e.id
                                        ? Border.all(color: Colors.red)
                                        : null,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: currentState.downloadingType?.id == e.id
                                        ? []
                                        : const [
                                            BoxShadow(
                                              color: Colors.grey,
                                              blurRadius: 5,
                                            ),
                                          ]),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.music_note),
                                    const SizedBox(height: 5),
                                    TextWidget(
                                      text: e.name,
                                      textAlign: TextAlign.center,
                                      size: 15,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.9,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList()),
          ),
        ],
      );
    });
  }
}

class _VideosDownloadingInformation extends StatelessWidget {
  final PageController pageController;

  const _VideosDownloadingInformation({
    Key? key,
    required this.pageController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      var youtubeStateModel = context.watch<YoutubeVideoCubit>().state.youtubeVideoStateModel;
      var downloadingVideoStateModel = context.watch<VideoDownloadingCubit>().state;
      return SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () {
                  pageController.animateToPage(((pageController.page ?? 0) - 1).toInt(),
                      duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
                },
                icon: const Icon(Icons.arrow_back)),
            const SizedBox(height: 10),
            if (youtubeStateModel.downloadingType?.id == 1)
              Expanded(
                child: ListView.builder(
                    itemCount: 3, itemBuilder: (context, index) => const SizedBox()),
              )
            else if (youtubeStateModel.downloadingType?.id == 2)
              Expanded(
                child: ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    itemCount: youtubeStateModel.videosWithSound.length,
                    itemBuilder: (context, index) {
                      var video = youtubeStateModel.videosWithSound[index];
                      return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: "Качество: ${video.qualityLabel}",
                                color: Colors.black,
                                size: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.9,
                              ),
                              TextWidget(
                                text: "Размер: ${video.size.totalMegaBytes.toStringAsFixed(2)} МБ",
                                color: Colors.black,
                                size: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.9,
                              ),
                            ],
                          ),
                        ),
                        if (downloadingVideoStateModel.tempDownloadingVideoInfo != null &&
                            downloadingVideoStateModel.tempDownloadingVideoInfo?.urlId ==
                                video.url.toString())
                          if (downloadingVideoStateModel is VideoDownloadingGettingInfoState)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          else if (downloadingVideoStateModel is VideoDownloadingLoadingState)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  value: downloadingVideoStateModel
                                      .tempDownloadingVideoInfo?.downloadingProgress,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          else if (downloadingVideoStateModel is VideoDownloadingErrorState)
                            const TextWidget(text: "Error downloading")
                          else
                            const SizedBox()
                        else
                          Row(
                            children: [
                              Tooltip(
                                message: "Download video in Gallery",
                                showDuration: const Duration(seconds: 10),
                                child: IconButton(
                                    onPressed: () =>
                                        context.read<YoutubeVideoCubit>().downloadVideo(
                                              video,
                                              DownloadingStoragePath.gallery,
                                            ),
                                    icon: SizedBox(
                                        width: 40,
                                        height: 40,
                                        child: Image.asset(
                                          'assets/download_icons/gallery_save.png',
                                        ))),
                              ),
                              Tooltip(
                                message: "Download video in App Storage",
                                showDuration: const Duration(seconds: 10),
                                child: IconButton(
                                    onPressed: () =>
                                        context.read<YoutubeVideoCubit>().downloadVideo(
                                              video,
                                              DownloadingStoragePath.appStorage,
                                            ),
                                    icon: SizedBox(
                                        width: 35,
                                        height: 35,
                                        child: Image.asset(
                                            'assets/download_icons/in_app_download.png'))),
                              )
                            ],
                          )
                      ]);
                    }),
              )
          ],
        ),
      );
    });
  }
}
