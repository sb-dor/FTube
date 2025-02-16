import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/widgets/playlist_widgets/loaded_playlist_widget.dart';
import 'package:youtube/core/widgets/playlist_widgets/loading_playlist_widget.dart';
import 'package:youtube/features/library_inner_screens/blocs/playlist_inner_screen_bloc/playlist_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/blocs/playlist_inner_screen_bloc/playlist_inner_screen_event.dart';
import 'package:youtube/features/library_inner_screens/blocs/playlist_inner_screen_bloc/playlist_inner_screen_state.dart';

class PlaylistInnerScreen extends StatefulWidget {
  const PlaylistInnerScreen({super.key});

  @override
  State<PlaylistInnerScreen> createState() => _PlaylistInnerScreenState();
}

class _PlaylistInnerScreenState extends State<PlaylistInnerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PlaylistInnerScreenBloc>().add(RefreshInnerPlaylistScreen());
    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
        context.read<PlaylistInnerScreenBloc>().add(PaginateInnerPlaylistScreen());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final playlistInnerScreenBloc = context.watch<PlaylistInnerScreenBloc>();

      // data
      final playlistInnerScreenStateModel =
          playlistInnerScreenBloc.state.playlistInnerScreenStateModel;
      return Scaffold(
        appBar: AppBar(
          title: const Text("Playlists"),
          scrolledUnderElevation: 0,
        ),
        body: RefreshIndicator(
          color: Colors.red,
          onRefresh: () async =>
              context.read<PlaylistInnerScreenBloc>().add(RefreshInnerPlaylistScreen()),
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (playlistInnerScreenBloc.state is LoadingPlaylistInnerState)
                const LoadingPlaylistWidget(
                  gridView: true,
                )
              else if (playlistInnerScreenBloc.state is ErrorPlaylistInnerState)
                const SizedBox()
              else if (playlistInnerScreenBloc.state is LoadedPlaylistInnerState &&
                  playlistInnerScreenStateModel.playlists.isEmpty)
                const SizedBox()
              else
                LoadedPlaylistWidget(
                  playlist: playlistInnerScreenStateModel.playlists,
                  gridView: true,
                ),
              if (playlistInnerScreenStateModel.hasMore)
                const Column(
                  children: [
                    SizedBox(height: 15),
                    SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      );
    },);
  }
}
