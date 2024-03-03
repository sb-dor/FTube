import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/home_screen/usecases/open_video_screen/open_video_screen.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';

class HistoryInnerScreenLoadedWidget extends StatelessWidget {
  const HistoryInnerScreenLoadedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final historyInnerScreenBloc = context.watch<HistoryInnerScreenBloc>();

      // data
      final historyInnerScreenStateModel =
          historyInnerScreenBloc.state.historyInnerScreenStateModel;
      return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyInnerScreenStateModel.historyVideos.length,
          itemBuilder: (context, index) {
            final video = historyInnerScreenStateModel.historyVideos[index];
            return _Widget(
              baseVideoModelDb: video,
            );
          });
    });
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
      onTap: () => OpenVideoScreen.openVideoScreen(
        context: context,
        videoId: baseVideoModelDb?.videoId ?? '',
        videoThumb: baseVideoModelDb?.videoThumbnailUrl,
      ),
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
            SizedBox(width: 10),
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
