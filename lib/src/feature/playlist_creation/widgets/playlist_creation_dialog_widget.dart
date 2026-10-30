import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/common/widget/dialog_messenger_widget.dart';
import 'package:youtube/src/feature/playlist_creation/controller/playlist_creation_controller.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/controllers/playlist_creation_data_controller.dart';
import 'package:youtube/src/feature/playlist_creation/widgets/playlist_creation_config_widget.dart';

class PlaylistCreationDialogWidget extends StatefulWidget {
  const PlaylistCreationDialogWidget({super.key});

  @override
  State<PlaylistCreationDialogWidget> createState() => _PlaylistCreationDialogWidgetState();
}

class _PlaylistCreationDialogWidgetState extends State<PlaylistCreationDialogWidget> {
  late final _scope = PlaylistCreationConfigInhWidget.of(context);
  late final _controller = _scope.playlistCreationController;
  late final _dataController = _scope.playlistCreationDataController;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    // The listener's context is inside the dialog's messenger, so errors show above the dialog.
    return DialogMessengerWidget(
      builder: (context) => StateConsumer<PlaylistCreationController, PlaylistCreationState>(
        controller: _controller,
        listener: (context, controller, previous, current) {
          if (current is PlaylistCreation$CompletedState) {
            _scope.onCreated?.call(current.playlistId);
            Navigator.pop(context);
          } else if (current is PlaylistCreation$ErrorState) {
            showMessage(context, message: l10n.errorGeneric, isError: true);
          }
        },
        builder: (context, state, _) {
          final inProgress = state is PlaylistCreation$InProgressState;
          return PopScope(
            canPop: !inProgress,
            child: ListenableBuilder(
              listenable: _dataController,
              builder: (context, _) => AlertDialog(
                title: Text(l10n.playlistCreationTitle),
                content: TextField(
                  autofocus: true,
                  enabled: !inProgress,
                  maxLength: PlaylistCreationDataController.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  cursorColor: AppColors.accent,
                  onChanged: _dataController.setName,
                  onSubmitted: (_) => _scope.save(),
                  decoration: InputDecoration(
                    hintText: l10n.playlistCreationHint,
                    errorText: _dataController.showEmptyError
                        ? l10n.playlistCreationEmptyError
                        : null,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.accent),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: inProgress ? null : () => Navigator.pop(context),
                    child: Text(l10n.cancel, style: const TextStyle(color: AppColors.accent)),
                  ),
                  if (inProgress)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else
                    TextButton(
                      onPressed: _scope.save,
                      child: Text(
                        l10n.playlistCreationCreate,
                        style: TextStyle(
                          color: _dataController.isEmpty ? Colors.red.shade200 : AppColors.accent,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
