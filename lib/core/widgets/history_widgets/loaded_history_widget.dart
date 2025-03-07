import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/utils/reusable_global_widgets.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/home_screen/presentation/dialog_openers/open_video_screen/open_video_screen.dart';
import 'package:youtube/features/library_inner_screens/presentation/pages/history_inner_screen/history_inner_screen.dart';
import 'package:youtube/features/library_screen/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_event.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/library_module_title_widget/library_module_title_widget.dart';
import 'package:youtube/core/widgets/image_loader_widget.dart';
import 'package:youtube/core/widgets/text_widget.dart';
import 'package:youtube/features/top_overlay_feature/view/overlay_opener/top_overlay_logic.dart';
import 'package:youtube/features/youtube_video_player_screen/presentation/bloc/youtube_video_cubit.dart';

class LoadedHistoryWidget extends StatelessWidget {
  final List<BaseVideoModelDb> videos;
  final BuildContext parentContext;

  const LoadedHistoryWidget({
    super.key,
    required this.videos,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LibraryModuleTitleWidget(
          title: 'History',
          onButtonTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryInnerScreen(),
                ),
              ),
          showAdd: false,
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 210,
          child: ListView.separated(
            separatorBuilder: (context, index) => const SizedBox(width: 10),
            itemCount: videos.length,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final video = videos[index];
              return _Widget(videoModelDb: video, parentContext: parentContext);
            },
          ),
        ),
      ],
    );
  }
}

class _Widget extends StatelessWidget {
  final BaseVideoModelDb? videoModelDb;
  final BuildContext parentContext;

  const _Widget({required this.videoModelDb, required this.parentContext});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        TopOverlayLogic.instance.removeOverlay();
        final Video video = Video.fromBaseVideoModelDb(videoModelDb);
        context.read<HistoryBloc>().add(AddOnHistoryEvent(video: video));
        await OpenVideoScreen.openVideoScreen(
          context: context,
          parentContext: parentContext,
          videoId: videoModelDb?.videoId ?? '',
          videoThumb: videoModelDb?.videoThumbnailUrl,
          showOverlay: () {
            // debugPrint"calling on: before mounted");
            if (context.mounted) {
              // debugPrint"calling on: after mounted");
              WidgetsBinding.instance.addPostFrameCallback((_) {
                final model =
                    context
                        .read<YoutubeVideoCubit>()
                        .state
                        .youtubeVideoStateModel;
                // debugPrint"setting overlay run id: ${model.videoUrlForOverlayRun ?? ''}");
                // debugPrint
                //     "setting overlay run duration: ${model.lastVideoDurationForMediaBackground ?? ''}");
                TopOverlayLogic.instance.showOverlay(
                  context,
                  model.videoUrlForOverlayRun ?? '',
                  model.lastVideoDurationForMediaBackground,
                );
              });
            }
          },
        ).then((value) {
          if (context.mounted) {
            context.read<HistoryBloc>().add(GetHistoryEvent());
            context.read<PlaylistsBloc>().add(GetPlaylistsEvent());
          }
        });
      },
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 130,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ImageLoaderWidget(
                        url: videoModelDb?.videoThumbnailUrl ?? '',
                        errorImageUrl:
                            'assets/custom_images/custom_user_image.png',
                        boxFit: BoxFit.cover,
                      ),
                    ),
                    if (videoModelDb?.duration != null)
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Container(
                          padding: const EdgeInsets.only(
                            top: 3,
                            bottom: 3,
                            right: 8,
                            left: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: TextWidget(
                            text: "${videoModelDb?.duration}",
                            color: Colors.white,
                            size: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: TextWidget(
                              text: "${videoModelDb?.title}",
                              maxLines: 2,
                              size: 15,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.9,
                              overFlow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: IconButton(
                              style: const ButtonStyle(
                                padding: WidgetStatePropertyAll(
                                  EdgeInsets.all(0),
                                ),
                              ),
                              onPressed: () {
                                ReusableGlobalWidgets.instance
                                    .showPlaylistAddingPopup(
                                      context: context,
                                      videoModelDb: videoModelDb,
                                    );
                              },
                              icon: const Center(
                                child: Icon(Icons.more_vert, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: ImageLoaderWidget(
                                url: videoModelDb?.channelThumb ?? '',
                                errorImageUrl:
                                    'assets/custom_images/custom_user_image.png',
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: TextWidget(
                              text: "${videoModelDb?.channelName}",
                              maxLines: 1,
                              size: 13,
                              color: Colors.grey,
                              overFlow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
