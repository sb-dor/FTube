import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/history_bloc/history_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_event.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_state.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/history_widgets/error_history_widget.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/history_widgets/loaded_history_widget.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/history_widgets/loading_history_widget.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/playlist_widgets/error_playlist_widget.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/playlist_widgets/loaded_playlist_widget.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/widgets/playlist_widgets/loading_playlist_widget.dart';

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
                  const LoadedHistoryWidget(),
                if (playlistBloc.state is LoadingPlaylistsState)
                  const LoadingPlaylistWidget()
                else if (playlistBloc.state is ErrorPlaylistsState)
                  const ErrorPlaylistWidget()
                else if (playlistBloc.state is LoadedPlaylistsState &&
                    playlistStateModel.playlist.isEmpty)
                  const SizedBox()
                else
                  const LoadedPlaylistWidget(),
                const SizedBox(height: 30)
              ],
            ),
          ),
        );
      },
    );
  }
}
