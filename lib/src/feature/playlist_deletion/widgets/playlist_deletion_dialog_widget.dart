import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/feature/library/widgets/confirmation_dialog_widget.dart';
import 'package:youtube/src/feature/playlist_deletion/controller/playlist_deletion_controller.dart';
import 'package:youtube/src/feature/playlist_deletion/widgets/playlist_deletion_config_widget.dart';

class PlaylistDeletionDialogWidget extends StatefulWidget {
  const PlaylistDeletionDialogWidget({super.key});

  @override
  State<PlaylistDeletionDialogWidget> createState() => _PlaylistDeletionDialogWidgetState();
}

class _PlaylistDeletionDialogWidgetState extends State<PlaylistDeletionDialogWidget> {
  late final _scope = PlaylistDeletionConfigInhWidget.of(context);
  late final _controller = _scope.playlistDeletionController;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return StateConsumer<PlaylistDeletionController, PlaylistDeletionState>(
      controller: _controller,
      listener: (context, controller, previous, current) {
        if (current is PlaylistDeletion$CompletedState) {
          _scope.onSuccessfullyDelete?.call();
          Navigator.pop(context);
        } else if (current is PlaylistDeletion$ErrorState) {
          showMessage(context, message: l10n.errorGeneric, isError: true);
        }
      },
      builder: (context, state, _) => ConfirmationDialogWidget(
        title: l10n.playlistDeletionTitle,
        content: l10n.playlistDeletionContent(_scope.name),
        confirmLabel: l10n.delete,
        inProgress: state is PlaylistDeletion$InProgressState,
        onConfirm: _scope.delete,
      ),
    );
  }
}
