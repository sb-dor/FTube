import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
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
    return StateConsumer<PlaylistCreationController, PlaylistCreationState>(
      controller: _controller,
      listener: (context, controller, previous, current) {
        if (current is PlaylistCreation$CompletedState) {
          _scope.onCreated?.call(current.playlistId);
          Navigator.pop(context);
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
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
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
                  if (state is PlaylistCreation$ErrorState)
                    Text(
                      l10n.errorGeneric,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                ],
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
    );
  }
}
