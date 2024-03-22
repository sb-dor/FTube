import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/playlists_db/playlist_model_db/playlist_model_db.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/playlist_videos_inner_screen_bloc.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/playlist_videos_inner_screen_event.dart';
import 'package:youtube/features/library_inner_screens/presentation/blocs/playlist_videos_inner_screen_bloc/playlist_videos_inner_screen_state.dart';
import 'package:youtube/features/widgets/history_inner_screen_widgets/history_inner_screen_error_widget.dart';
import 'package:youtube/features/widgets/history_inner_screen_widgets/history_inner_screen_loaded_widget.dart';
import 'package:youtube/features/widgets/history_inner_screen_widgets/history_inner_screen_loading_widget.dart';

class PlaylistVideosInnerScreen extends StatefulWidget {
  final PlaylistModelDb? playlistModelDb;

  const PlaylistVideosInnerScreen({
    super.key,
    required this.playlistModelDb,
  });

  @override
  State<PlaylistVideosInnerScreen> createState() => _PlaylistVideosInnerScreenState();
}

class _PlaylistVideosInnerScreenState extends State<PlaylistVideosInnerScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<PlaylistVideosInnerScreenBloc>().add(RefreshPlaylistVideosInnerScreenEvent(
          playlistModelDb: widget.playlistModelDb,
        ));
    _scrollController.addListener(() {
      if (_scrollController.offset == _scrollController.position.maxScrollExtent) {
        context.read<PlaylistVideosInnerScreenBloc>().add(
              PaginatePlaylistVideosInnerScreenEvent(
                playlistModelDb: widget.playlistModelDb,
              ),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final playlistVideosInnerScreenBloc = context.watch<PlaylistVideosInnerScreenBloc>();

      // data
      final playlistVideosInnerScreenStateModel =
          playlistVideosInnerScreenBloc.state.playlistVideosInnerScreenStateModel;

      return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            widget.playlistModelDb?.name ?? '-',
            style: const TextStyle(fontSize: 22),
          ),
          scrolledUnderElevation: 0,
        ),
        body: RefreshIndicator(
          color: Colors.red,
          onRefresh: () async => context
              .read<PlaylistVideosInnerScreenBloc>()
              .add(RefreshPlaylistVideosInnerScreenEvent(
                playlistModelDb: widget.playlistModelDb,
              )),
          child: ListView(
            padding: const EdgeInsets.only(left: 10, right: 10),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: _scrollController,
            children: [
              if (playlistVideosInnerScreenBloc.state is LoadingPlaylistVideosInnerScreenState)
                const HistoryInnerScreenLoadingWidget()
              else if (playlistVideosInnerScreenBloc.state is ErrorPlaylistVideosInnerScreenState)
                const HistoryInnerScreenErrorWidget()
              else if (playlistVideosInnerScreenBloc.state is LoadedPlaylistVideosInnerScreenState)
                HistoryInnerScreenLoadedWidget(
                  historyVideos: playlistVideosInnerScreenStateModel.playlistVideos,
                ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    });
  }
}
