import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/popups/create_playlist_popup/create_playlist_popup.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/library_module_title_widget/library_module_title_widget.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';

class LoadedPlaylistWidget extends StatelessWidget {
  const LoadedPlaylistWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final playListStates = context.watch<PlaylistsBloc>().state;

        // data
        final playListStateModel = playListStates.playListsStateModel;
        return Column(
          children: [
            const SizedBox(height: 30),
            LibraryModuleTitleWidget(
              title: 'Playlists',
              onButtonTap: () {},
              showAdd: true,
              onAddTap: () => showDialog(
                context: context,
                builder: (context) => const CreatePlayListPopup(),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 250,
              child: ListView.separated(
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemCount: playListStateModel.playlist.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  final playList = playListStateModel.playlist[index];
                  return _Widget(playlist: playList);
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final PlaylistModelDb? playlist;

  const _Widget({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          height: 130,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 15,
                left: 15,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: const Offset(0.5, 0.5),
                        blurRadius: 5,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: (playlist?.videos ?? []).isNotEmpty
                      ? Stack(
                          children: [
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: ImageLoaderWidget(
                                  url: playlist?.videos?.first.videoThumbnailUrl ?? '',
                                  errorImageUrl: 'assets/custom_images/custom_user_image.png',
                                  boxFit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.ondemand_video_sharp,
                                      color: Colors.white,
                                    ),
                                    TextWidget(
                                      text: "${playlist?.videos?.length ?? 0}",
                                      color: Colors.white,
                                    )
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      : Image.asset(
                          'assets/custom_images/empty_data.png',
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextWidget(
          text: "${playlist?.name}",
          size: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.9,
        )
      ],
    );
  }
}
