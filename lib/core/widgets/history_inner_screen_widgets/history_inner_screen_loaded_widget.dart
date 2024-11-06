import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/core/youtube_data_api/models/video.dart';
import 'package:youtube/features/home_screen/domain/usecases/open_video_screen/open_video_screen.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_event.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class HistoryInnerScreenLoadedWidget extends StatelessWidget {
  final List<BaseVideoModelDb> historyVideos;

  const HistoryInnerScreenLoadedWidget({
    super.key,
    required this.historyVideos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: historyVideos.length,
      itemBuilder: (context, index) {
        final video = historyVideos[index];
        return _Widget(
          baseVideoModelDb: video,
        );
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final BaseVideoModelDb? baseVideoModelDb;

  const _Widget({
    Key? key,
    required this.baseVideoModelDb,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        Video video = Video.fromBaseVideoModelDb(baseVideoModelDb);
        context.read<HistoryBloc>().add(AddOnHistoryEvent(video: video));
        await OpenVideoScreen.openVideoScreen(
          context: context,
          videoId: baseVideoModelDb?.videoId ?? '',
          videoThumb: baseVideoModelDb?.videoThumbnailUrl,
        ).then(
          (value) {
            if (context.mounted) {
              context.read<HistoryBloc>().add(GetHistoryEvent());
              context.read<PlaylistsBloc>().add(GetPlaylistsEvent());
            }
          },
        );
      },
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.1,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageLoaderWidget(
                  url: baseVideoModelDb?.videoThumbnailUrl ?? '',
                  errorImageUrl: 'assets/custom_images/custom_user_image.png',
                  boxFit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: baseVideoModelDb?.title ?? '-',
                    maxLines: 3,
                    overFlow: TextOverflow.ellipsis,
                    size: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.9,
                  ),
                  TextWidget(
                    text: baseVideoModelDb?.channelName ?? '-',
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                    size: 13,
                    color: Colors.grey,
                  ),
                  TextWidget(
                    text: baseVideoModelDb?.views ?? '-',
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                    size: 13,
                    color: Colors.grey,
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
