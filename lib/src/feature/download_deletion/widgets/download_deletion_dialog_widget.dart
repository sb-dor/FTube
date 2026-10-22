import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/download_deletion/controller/download_deletion_controller.dart';
import 'package:youtube/src/feature/download_deletion/widgets/download_deletion_config_widget.dart';

class DownloadDeletionDialogWidget extends StatefulWidget {
  const DownloadDeletionDialogWidget({super.key});

  @override
  State<DownloadDeletionDialogWidget> createState() => _DownloadDeletionDialogWidgetState();
}

class _DownloadDeletionDialogWidgetState extends State<DownloadDeletionDialogWidget> {
  late final _scope = DownloadDeletionConfigInhWidget.of(context);
  late final _controller = _scope.downloadDeletionController;

  @override
  Widget build(BuildContext context) {
    final localization = Localization.of(context);
    return StateConsumer<DownloadDeletionController, DownloadDeletionState>(
      controller: _controller,
      listener: (context, controller, previous, current) {
        if (current is DownloadDeletion$CompletedState) {
          _scope.onSuccessfullyDelete?.call();
          Navigator.pop(context);
        }
      },
      builder: (context, state, _) {
        final inProgress = state is DownloadDeletion$InProgressState;
        return PopScope(
          canPop: !inProgress,
          child: AlertDialog(
            title: Text(localization.downloadDeletionTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(localization.downloadDeletionContent(_scope.file.title)),
                if (state is DownloadDeletion$ErrorState) ...[
                  const SizedBox(height: 12),
                  Text(
                    localization.errorGeneric,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: inProgress ? null : () => Navigator.pop(context),
                child: Text(localization.cancel),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                onPressed: inProgress ? null : _scope.delete,
                child: inProgress
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(localization.delete),
              ),
            ],
          ),
        );
      },
    );
  }
}
