import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_event.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_state.dart';
import 'package:youtube/features/widgets/history_inner_screen_widgets/downloaded_file_loaded_widget.dart';

class LibraryDownloadedPage extends StatefulWidget {
  const LibraryDownloadedPage({super.key});

  @override
  State<LibraryDownloadedPage> createState() => _LibraryDownloadedPageState();
}

class _LibraryDownloadedPageState extends State<LibraryDownloadedPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<LibraryDownloadsBloc>().add(InitLibraryDownloadsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final libraryDownloadsBloc = context.watch<LibraryDownloadsBloc>();

        // data

        final libraryDownloadsStateModel = libraryDownloadsBloc.state.libraryDownloadsStateModel;

        return Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            title: const Text(
              "In-App downloads",
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.only(left: 10, right: 10),
            children: [
              if (libraryDownloadsBloc.state is LibraryDownloadsLoadedState)
                DownloadedFileLoadedWidget(
                  downloadedFiles: libraryDownloadsStateModel.files,
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}
