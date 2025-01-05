import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/pages/playlist_inner_screen/playlist_inner_screen.dart';
import 'package:youtube/features/library_screen/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_event.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_state.dart';
import 'package:youtube/core/widgets/history_widgets/error_history_widget.dart';
import 'package:youtube/core/widgets/history_widgets/loaded_history_widget.dart';
import 'package:youtube/core/widgets/history_widgets/loading_history_widget.dart';
import 'package:youtube/core/widgets/playlist_widgets/error_playlist_widget.dart';
import 'package:youtube/core/widgets/playlist_widgets/loaded_playlist_widget.dart';
import 'package:youtube/core/widgets/playlist_widgets/loading_playlist_widget.dart';
import 'popups/create_playlist_popup/create_playlist_popup.dart';
import 'widgets/library_download_files_widget/library_downloaded_files_widget.dart';
import 'widgets/library_module_title_widget/library_module_title_widget.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  void initState() {
    super.initState();

    context.read<HistoryBloc>().add(GetHistoryEvent());
    context.read<HistoryBloc>().add(InitLengthOfDownloadedFiles());
    context.read<PlaylistsBloc>().add(GetPlaylistsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final historyBloc = context.watch<HistoryBloc>();
        final playlistBloc = context.watch<PlaylistsBloc>();

        // data
        final historyStateModel = historyBloc.state.historyStateModel;
        final playlistStateModel = playlistBloc.state.playListsStateModel;
        //
        return Scaffold(
          body: RefreshIndicator(
            color: Colors.red,
            onRefresh: () async {
              context.read<HistoryBloc>().add(GetHistoryEvent());
              context.read<PlaylistsBloc>().add(GetPlaylistsEvent());
            },
            child: ListView(
              padding: const EdgeInsets.only(left: 10, right: 10),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (historyBloc.state is LoadingHistoryState)
                  const LoadingHistoryWidget()
                else if (historyBloc.state is ErrorHistoryState)
                  const ErrorHistoryWidget()
                else if (historyBloc.state is LoadedHistoryState &&
                    historyStateModel.videos.isEmpty)
                  const SizedBox()
                else
                  LoadedHistoryWidget(
                    videos: historyStateModel.videos,
                    parentContext: context,
                  ),

                //
                if (playlistBloc.state is LoadedPlaylistsState)
                  Column(
                    children: [
                      const SizedBox(height: 30),
                      LibraryModuleTitleWidget(
                        title: 'Playlists',
                        onButtonTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlaylistInnerScreen(),
                            ),
                          );
                        },
                        showAdd: true,
                        showSeeAll: playlistBloc.state is LoadedPlaylistsState &&
                            playlistStateModel.playlist.isNotEmpty,
                        onAddTap: () => showDialog(
                          context: context,
                          builder: (context) => const CreatePlayListPopup(),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                //
                if (playlistBloc.state is LoadingPlaylistsState)
                  const LoadingPlaylistWidget()
                else if (playlistBloc.state is ErrorPlaylistsState)
                  const ErrorPlaylistWidget()
                else if (playlistBloc.state is LoadedPlaylistsState &&
                    playlistStateModel.playlist.isEmpty)
                  const SizedBox()
                else
                  Column(
                    children: [
                      LoadedPlaylistWidget(
                        playlist: playlistStateModel.playlist,
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                if (historyStateModel.lengthOfDownloadedFiles != 0)
                  const LibraryDownloadedFilesWidget(),
                const SizedBox(height: 120)
              ],
            ),
          ),
        );
      },
    );
  }
}
