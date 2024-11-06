import 'package:flutter/material.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_inner_screens/presentation/pages/playlist_videos_inner_screen/playlist_videos_inner_screen.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class LoadedPlaylistWidget extends StatelessWidget {
  final List<PlaylistModelDb> playlist;
  final bool listView;
  final bool gridView;

  const LoadedPlaylistWidget({
    super.key,
    required this.playlist,
    this.listView = true,
    this.gridView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (gridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: playlist.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            itemBuilder: (context, index) {
              final playlist = this.playlist[index];
              return _Widget(
                playlist: playlist,
                gridView: gridView,
              );
            },
          )
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemCount: playlist.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                final playList = playlist[index];
                return _Widget(playlist: playList);
              },
            ),
          ),
      ],
    );
  }
}

class _Widget extends StatelessWidget {
  final PlaylistModelDb? playlist;
  final bool gridView;

  const _Widget({
    Key? key,
    required this.playlist,
    this.gridView = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaylistVideosInnerScreen(
            playlistModelDb: playlist,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: gridView ? CrossAxisAlignment.center : CrossAxisAlignment.start,
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
                  top: 5,
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
          SizedBox(
            width: 150,
            child: TextWidget(
              text: "${playlist?.name}",
              size: 16,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.9,
              maxLines: 1,
              overFlow: TextOverflow.ellipsis,
            ),
          )
        ],
      ),
    );
  }
}
