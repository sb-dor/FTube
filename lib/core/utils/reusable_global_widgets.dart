import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube/core/db/base_video_model_db/base_video_model_db.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_bloc.dart';
import 'package:youtube/features/library_screen/bloc/playlists_bloc/playlists_event.dart';
import 'package:youtube/features/library_screen/presentation/pages/main_library_page/popups/create_playlist_popup/select_playlist_popup.dart';

import 'global_context_helper.dart';

class ReusableGlobalWidgets {
  static ReusableGlobalWidgets? _instance;

  static ReusableGlobalWidgets get instance =>
      _instance ??= ReusableGlobalWidgets._();

  ReusableGlobalWidgets._();

  BuildContext context =
      GlobalContextHelper.instance.globalNavigatorContext.currentState!.context;

  Future<void> showPlaylistAddingPopup({
    required BuildContext context,
    required BaseVideoModelDb? videoModelDb,
    VoidCallback? onFunc,
  }) async {
    context.read<PlaylistsBloc>().add(GetPlaylistsEvent());
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return SelectPlaylistPopup(videoModelDb: videoModelDb);
      },
    ).then((value) {
      if (onFunc != null) {
        onFunc();
      } else {
        if (context.mounted) {
          context.read<PlaylistsBloc>().add(ClearTempPlaylist());
        }
      }
    });
  }
}
