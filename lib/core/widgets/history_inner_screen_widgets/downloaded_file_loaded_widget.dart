import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_downloaded_file_model/base_downloaded_file_model.dart';
import 'package:youtube/core/utils/reusable_global_functions.dart';
import 'package:youtube/features/library_downloads/bloc/library_downloads_bloc.dart';
import 'package:youtube/features/library_downloads/bloc/library_downloads_event.dart';
import 'package:youtube/features/library_downloads/bloc/state_model/library_downloads_state_model.dart';
import 'package:youtube/core/widgets/image_loader_widget.dart';
import 'package:youtube/core/widgets/text_widget.dart';
import 'package:youtube/features/library_downloads/presentation/dialog_openers/open_library_downloads_audio_listener_popup/open_library_downloads_audio_listener_popup.dart';

class DownloadedFileLoadedWidget extends StatelessWidget {
  final List<BaseDownloadedFileModel> downloadedFiles;

  const DownloadedFileLoadedWidget({super.key, required this.downloadedFiles});

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

  const _Widget({required this.downloadedFile, required this.libraryDownloadsStateModel});

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
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      child: Center(
                        child: TextWidget(
                          text:
                              "${ReusableGlobalFunctions.instance.fileExtensionName(downloadedFile)}",
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.9,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
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
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Tooltip(
                      message: libraryDownloadsStateModel.toolTipMessage(downloadedFile),
                      child: IconButton(
                        onPressed:
                            () => context.read<LibraryDownloadsBloc>().add(
                              SaveAppStorageFileInGalleryEvent(
                                baseDownloadedFileModel: downloadedFile,
                              ),
                            ),
                        icon:
                            ReusableGlobalFunctions.instance.fileExtensionName(downloadedFile) ==
                                    "mp4"
                                ? SizedBox(
                                  width: 25,
                                  height: 25,
                                  child: Image.asset("assets/download_icons/gallery_save.png"),
                                )
                                : const Icon(Icons.download, size: 20),
                      ),
                    ),
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
