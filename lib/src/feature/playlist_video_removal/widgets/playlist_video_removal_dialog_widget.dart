import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/model/playlist_summary.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/common/widget/confirmation_dialog_widget.dart';
import 'package:youtube/src/feature/playlist_video_removal/controller/playlist_video_removal_controller.dart';
import 'package:youtube/src/feature/playlist_video_removal/widgets/playlist_video_removal_config_widget.dart';

class PlaylistVideoRemovalDialogWidget extends StatefulWidget {
  const PlaylistVideoRemovalDialogWidget({super.key});

  @override
  State<PlaylistVideoRemovalDialogWidget> createState() => _PlaylistVideoRemovalDialogWidgetState();
}

class _PlaylistVideoRemovalDialogWidgetState extends State<PlaylistVideoRemovalDialogWidget> {
  late final _scope = PlaylistVideoRemovalConfigInhWidget.of(context);
  late final _controller = _scope.playlistVideoRemovalController;

  /// The dialog's own context, so an error snackbar shows above the dialog, not under it.
  BuildContext? _dialogContext;

  void _confirm(BuildContext dialogContext) {
    _dialogContext = dialogContext;
    _scope.remove();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return StateConsumer<PlaylistVideoRemovalController, PlaylistVideoRemovalState>(
      controller: _controller,
      listener: (context, controller, previous, current) {
        if (current is PlaylistVideoRemoval$CompletedState) {
          _scope.onSuccessfullyDelete?.call();
          Navigator.pop(context);
        } else if (current is PlaylistVideoRemoval$ErrorState) {
          showMessage(_dialogContext ?? context, message: l10n.errorGeneric, isError: true);
        }
      },
      builder: (context, state, _) => ConfirmationDialogWidget(
        title: switch (_scope.playlist) {
          UserPlaylistSummary() => l10n.playlistVideoRemovalTitle,
          LikedPlaylistSummary() => l10n.playlistVideoRemovalUnlikeTitle,
        },
        content: l10n.playlistVideoRemovalContent(_scope.video.title),
        confirmLabel: l10n.playlistVideoRemovalConfirm,
        inProgress: state is PlaylistVideoRemoval$InProgressState,
        onConfirm: _confirm,
      ),
    );
  }
}
