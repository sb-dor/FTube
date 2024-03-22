import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/home_screen/usecases/open_video_screen/open_video_screen.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/history_inner_screen_bloc/history_inner_screen_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_event.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'package:youtube/youtube_data_api/models/video.dart';

class DownloadedFileLoadedWidget extends StatelessWidget {
  final List<BaseDownloadedFileModel> downloadedFiles;

  const DownloadedFileLoadedWidget({
    super.key,
    required this.downloadedFiles,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: downloadedFiles.length,
      itemBuilder: (context, index) {
        final file = downloadedFiles[index];
        return _Widget(
          downloadedFile: file,
        );
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final BaseDownloadedFileModel? downloadedFile;

  const _Widget({
    Key? key,
    required this.downloadedFile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.1,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ImageLoaderWidget(
                  url: downloadedFile?.imagePath ?? '',
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
                    text: downloadedFile?.name ?? '-',
                    maxLines: 3,
                    overFlow: TextOverflow.ellipsis,
                    size: 15,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.9,
                  ),
                  TextWidget(
                    text: downloadedFile?.channelName ?? '-',
                    maxLines: 1,
                    overFlow: TextOverflow.ellipsis,
                    size: 13,
                    color: Colors.grey,
                  ),
                  TextWidget(
                    text: downloadedFile?.views ?? '-',
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
