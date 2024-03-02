import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/presentation/bloc/playlists_bloc/playlists_event.dart';
import 'package:youtube/widgets/text_widget.dart';
import 'package:youtube/widgets/wrapped_popup_widget.dart';

import 'create_playlist_popup.dart';

class SelectPlaylistPopup extends StatelessWidget {
  final BaseVideoModelDb? videoModelDb;

  const SelectPlaylistPopup({
    super.key,
    required this.videoModelDb,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      final playlistBloc = context.watch<PlaylistsBloc>();

      // data
      final playlistStateModel = playlistBloc.state.playListsStateModel;
      return WrappedPopupWidget(
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  child: TextWidget(
                    text: "Select playlist",
                    size: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const CreatePlayListPopup(),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: Colors.blue,
                    size: 20,
                  ),
                  label: const Text(
                    "New",
                    style: TextStyle(color: Colors.blue, fontSize: 18),
                  ),
                )
              ],
            ),
            const SizedBox(height: 5),
            Divider(
              height: 0,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 5),
            ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              shrinkWrap: true,
              itemCount: playlistStateModel.playlist.length,
              itemBuilder: (context, index) {
                final playlist = playlistStateModel.playlist[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: playlistStateModel.tempSelectedPlaylist?.id == playlist.id,
                      onChanged: (v) {
                        context
                            .read<PlaylistsBloc>()
                            .add(SelectTempPlaylist(playlistModelDb: playlist));
                      },
                    ),
                    Expanded(
                      child: TextWidget(
                        text: "${playlist.name}",
                        size: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                );
              },
            ),
            const SizedBox(height: 5),
            if (playlistStateModel.playlist.isNotEmpty)
              Column(
                children: [
                  Divider(
                    height: 0,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 5),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        if (playlistStateModel.tempSelectedPlaylist == null) return;
                        context.read<PlaylistsBloc>().add(
                              SaveInPlaylistEvent(
                                videoModelDb: videoModelDb,
                                playlistModelDb: null,
                              ),
                            );
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.check,
                        size: 20,
                        color: playlistStateModel.tempSelectedPlaylist == null
                            ? Colors.blue.shade200
                            : Colors.blue,
                      ),
                      label: Text(
                        "Done",
                        style: TextStyle(
                          fontSize: 18,
                          color: playlistStateModel.tempSelectedPlaylist == null
                              ? Colors.blue.shade200
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 10),
          ],
        ),
      );
    });
  }
}
