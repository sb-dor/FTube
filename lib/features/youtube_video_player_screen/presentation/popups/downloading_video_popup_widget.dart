import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:youtube/core/utils/analytics/analytics_event.dart';
import 'package:youtube/core/utils/enums.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/initialization/models/dependency_container.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_states.dart';
import 'package:youtube/features/youtube_video_player_screen/domain/entities/dowloading_type.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/audio_downloading_cubit/audio_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/audio_downloading_cubit/audio_downloading_states.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_downloading_cubit/video_downloading_cubit.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/cubits/video_downloading_cubit/video_downloading_states.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class DownloadingVideoPopupWidget extends StatefulWidget {
  const DownloadingVideoPopupWidget({super.key});

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
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(
      builder: (context, state) {
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
                    _position =
                        MediaQuery.of(context).size.height *
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
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        Container(
                          height: _position,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            ),
                          ),
                          child: _screens[index],
                        ),
                      ],
                    );
                  },
                );
              } else {
                return Container(height: 130);
              }
            },
          ),
        );
      },
    );
  }
}

class _SelectDownloadingTypeScreen extends StatelessWidget {
  final PageController pageController;

  const _SelectDownloadingTypeScreen({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<YoutubeVideoCubit, YoutubeVideoStates>(
      builder: (context, state) {
        final currentState = state.youtubeVideoStateModel;
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 130,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Row(
                children:
                    DownloadingType.types
                        .map(
                          (e) => Expanded(
                            child: Center(
                              child: GestureDetector(
                                onTap: () async {
                                  context.read<YoutubeVideoCubit>().clickTypeOfDownloadingVideo(e);
                                  pageController.animateToPage(
                                    ((pageController.page ?? 0) + 1).toInt(),
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.fastOutSlowIn,
                                  );

                                  await Provider.of<DependencyContainer>(context, listen: false)
                                      .analyticsReporter
                                      .report(TypeDownloaderButtonEvent(e.eventName));
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 175),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border:
                                        currentState.downloadingType?.id == e.id
                                            ? Border.all(color: Colors.red)
                                            : null,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow:
                                        currentState.downloadingType?.id == e.id
                                            ? []
                                            : const [BoxShadow(color: Colors.grey, blurRadius: 5)],
                                  ),
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
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VideosDownloadingInformation extends StatelessWidget {
  final PageController pageController;

  const _VideosDownloadingInformation({required this.pageController});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final youtubeStateModel = context.watch<YoutubeVideoCubit>().state.youtubeVideoStateModel;
        final downloadingVideoStateModel = context.watch<VideoDownloadingCubit>().state;
        final downloadingAudiosState = context.watch<AudioDownloadingCubit>().state;
        final arrayOfVideos =
            youtubeStateModel.tempMinAudioForVideo == null
                ? youtubeStateModel.videosWithSound
                : youtubeStateModel.allVideos;
        return SizedBox(
          child: ListView(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () {
                    pageController.animateToPage(
                      ((pageController.page ?? 0) - 1).toInt(),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                    );
                  },
                  icon: const Icon(Icons.arrow_back),
                ),
              ),
              const SizedBox(height: 10),
              if (youtubeStateModel.downloadingType?.id == 1)
                ListView.separated(
                  padding: const EdgeInsets.only(left: 10),
                  separatorBuilder: (context, index) => const Divider(height: 10),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: youtubeStateModel.audios.length,
                  itemBuilder: (context, index) {
                    final audio = youtubeStateModel.audios[index];
                    return Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: "Quality: ${audio.qualityLabel}",
                                color: Colors.black,
                                size: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.9,
                              ),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.9,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          "Size: ${audio.size.totalMegaBytes.toStringAsFixed(2)} МБ",
                                    ),
                                    if (!ReusableGlobalFunctions.instance.checkMp4FromURI(
                                      value: audio.url.toString(),
                                    ))
                                      TextSpan(
                                        text: " - ${audio.bitrate}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (audio.url.toString().trim() ==
                                  youtubeStateModel.tempMinAudioForVideo?.url.toString().trim())
                                TextWidget(
                                  text: "Recommended (Fast Download - ${audio.bitrate})",
                                  color: Colors.red,
                                  size: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.9,
                                ),
                            ],
                          ),
                        ),
                        if (audio.url.toString() ==
                            downloadingAudiosState.downloadingAudioInfo?.urlId)
                          if (downloadingAudiosState is AudioGettingInformationState)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.red),
                              ),
                            )
                          else if (downloadingAudiosState is AudioDownloadingState)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        () async =>
                                            await context
                                                .read<YoutubeVideoCubit>()
                                                .cancelTheAudio(),
                                    icon: const Icon(Icons.cancel_outlined),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      value:
                                          downloadingAudiosState
                                              .downloadingAudioInfo
                                              ?.downloadingProgress,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (downloadingAudiosState is AudioSavingOnStorageState)
                            const TextWidget(text: "Error downloading")
                          else
                            const SizedBox()
                        else
                          Row(
                            children: [
                              Tooltip(
                                message: "Download audio in Downloads folder",
                                showDuration: const Duration(seconds: 10),
                                child: IconButton(
                                  onPressed:
                                      () async =>
                                          await context.read<YoutubeVideoCubit>().downloadAudio(
                                            audioStreamInfo: audio,
                                            path: DownloadingStoragePath.phoneStorage,
                                          ),
                                  icon: const Icon(Icons.download),
                                ),
                              ),
                              Tooltip(
                                message: "Download audio in App Storage folder",
                                showDuration: const Duration(seconds: 10),
                                child: IconButton(
                                  onPressed:
                                      () async =>
                                          await context.read<YoutubeVideoCubit>().downloadAudio(
                                            audioStreamInfo: audio,
                                            path: DownloadingStoragePath.appStorage,
                                          ),
                                  icon: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: Image.asset('assets/download_icons/in_app_download.png'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                )
              else if (youtubeStateModel.downloadingType?.id == 2)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder:
                      (context, index) => Divider(height: 10, color: Colors.grey.shade300),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  itemCount: arrayOfVideos.length,
                  itemBuilder: (context, index) {
                    final video = arrayOfVideos[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextWidget(
                                text: "Quality: ${video.qualityLabel}",
                                color: Colors.black,
                                size: 16,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.9,
                              ),
                              RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.9,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          "Size: ${video.size.totalMegaBytes.toStringAsFixed(2)} МБ",
                                    ),
                                    if (!ReusableGlobalFunctions.instance.checkMp4FromURI(
                                      value: video.url.toString(),
                                    ))
                                      TextSpan(
                                        text: " - ${video.bitrate}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              if (ReusableGlobalFunctions.instance.checkMp4FromURI(
                                value: video.url.toString(),
                              ))
                                TextWidget(
                                  text: "Recommended (Fast download - ${video.bitrate})",
                                  color: Colors.red,
                                  size: 13,
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
                                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.red),
                              ),
                            )
                          else if (downloadingVideoStateModel is VideoDownloadingLoadingState)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        () async =>
                                            await context
                                                .read<YoutubeVideoCubit>()
                                                .cancelTheVideo(),
                                    icon: const Icon(Icons.cancel_outlined),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      value:
                                          downloadingVideoStateModel
                                              .tempDownloadingVideoInfo
                                              ?.downloadingProgress,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (downloadingVideoStateModel
                              is VideoDownloadingGettingAudioInformationState)
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Colors.blue,
                                ),
                              ),
                            )
                          else if (downloadingVideoStateModel is VideoDownloadingAudioState)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed:
                                        () async =>
                                            await context
                                                .read<YoutubeVideoCubit>()
                                                .cancelTheVideo(),
                                    icon: const Icon(Icons.cancel_outlined),
                                  ),
                                  const SizedBox(width: 10),
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      value:
                                          downloadingVideoStateModel
                                              .tempDownloadingAudioInfo
                                              ?.downloadingProgress,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
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
                                  onPressed:
                                      () => context.read<YoutubeVideoCubit>().downloadVideo(
                                        video,
                                        DownloadingStoragePath.phoneStorage,
                                      ),
                                  icon: SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Image.asset('assets/download_icons/gallery_save.png'),
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: "Download video in App Storage",
                                showDuration: const Duration(seconds: 10),
                                child: IconButton(
                                  onPressed:
                                      () => context.read<YoutubeVideoCubit>().downloadVideo(
                                        video,
                                        DownloadingStoragePath.appStorage,
                                      ),
                                  icon: SizedBox(
                                    width: 35,
                                    height: 35,
                                    child: Image.asset('assets/download_icons/in_app_download.png'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
