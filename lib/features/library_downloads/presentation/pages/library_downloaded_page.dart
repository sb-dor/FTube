import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_bloc.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_event.dart';
import 'package:youtube/features/library_downloads/presentation/bloc/library_downloads_state.dart';

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
            title: Text("In-app downloads"),
          ),
          body: ListView(
            children: [
              if (libraryDownloadsBloc.state is LibraryDownloadsLoadedState)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: libraryDownloadsStateModel.files.length,
                  itemBuilder: (context, index) {
                    final file = libraryDownloadsStateModel.files[index];
                    return Text(path.basename(file.path));
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
