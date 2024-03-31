import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/features/library_downloads/domain/usecases/open_library_downloads_audio_listener_popup/open_library_downloads_audio_listener_popup.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/state_model/library_downloads_state_model.dart';
import 'package:youtube/utils/reusable_global_functions.dart';
import 'package:youtube/widgets/image_loader_widget.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'package:youtube/x_injection_containers/injection_container.dart';

class DownloadedFileLoadedWidget extends StatelessWidget {
  final List<BaseDownloadedFileModel> downloadedFiles;

  const DownloadedFileLoadedWidget({
    super.key,
    required this.downloadedFiles,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final libraryDownloadBloc = context.watch<LibraryDownloadsBloc>();

        // data

        final libraryDownloadStateModel = libraryDownloadBloc.state.libraryDownloadsStateModel;

        return ListView.separated(
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: downloadedFiles.length,
          itemBuilder: (context, index) {
            final file = downloadedFiles[index];
            return _Widget(
              downloadedFile: file,
              libraryDownloadsStateModel: libraryDownloadStateModel,
            );
          },
        );
      },
    );
  }
}

class _Widget extends StatelessWidget {
  final BaseDownloadedFileModel? downloadedFile;
  final LibraryDownloadsStateModel libraryDownloadsStateModel;

  const _Widget({
    Key? key,
    required this.downloadedFile,
    required this.libraryDownloadsStateModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await OpenLibraryDownloadsAudioListenerPopup.openLibraryDownloadsAudioListenerPopup(
          context,
          downloadedFile,
        );
      },
      child: IntrinsicHeight(
        child: Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width / 2.1,
              height: 120,
              child: Stack(
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
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      padding: const EdgeInsets.only(left: 7, right: 7, top: 3, bottom: 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.black.withOpacity(0.4),
                      ),
                      child: Center(
                        child: TextWidget(
                          text: "${locator<ReusableGlobalFunctions>().fileExtensionName(downloadedFile)}",
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.9,
                          size: 12,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 10),
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
