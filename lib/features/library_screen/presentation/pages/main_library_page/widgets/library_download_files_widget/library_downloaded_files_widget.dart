import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_downloads/presentation/pages/library_downloaded_page.dart';
import 'package:youtube/features/library_screen/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/core/widgets/text_widget.dart';

class LibraryDownloadedFilesWidget extends StatelessWidget {
  const LibraryDownloadedFilesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final historyBloc = context.watch<HistoryBloc>();

        // data
        final historyStateModel = historyBloc.state.historyStateModel;
        return IntrinsicHeight(
          child: GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LibraryDownloadedPage(),
                  ),
                ),
            child: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 5),
              color: Colors.transparent,
              child: Row(
                children: [
                  const Icon(Icons.download),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const TextWidget(
                          text: "In-App downloads",
                          size: 15,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.9,
                        ),
                        TextWidget(
                          text:
                              "${historyStateModel.lengthOfDownloadedFiles} Files",
                          size: 13,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                          letterSpacing: 0.9,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
