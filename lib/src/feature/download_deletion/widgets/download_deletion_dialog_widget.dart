import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/common/widget/confirmation_dialog_widget.dart';
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

  /// The dialog's own context, so an error snackbar shows above the dialog, not under it.
  BuildContext? _dialogContext;

  void _confirm(BuildContext dialogContext) {
    _dialogContext = dialogContext;
    _scope.delete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return StateConsumer<DownloadDeletionController, DownloadDeletionState>(
      controller: _controller,
      listener: (context, controller, previous, current) {
        if (current is DownloadDeletion$CompletedState) {
          _scope.onSuccessfullyDelete?.call();
          Navigator.pop(context);
        } else if (current is DownloadDeletion$ErrorState) {
          showMessage(_dialogContext ?? context, message: l10n.errorGeneric, isError: true);
        }
      },
      builder: (context, state, _) => ConfirmationDialogWidget(
        title: l10n.downloadDeletionTitle,
        content: l10n.downloadDeletionContent(_scope.file.title),
        confirmLabel: l10n.delete,
        inProgress: state is DownloadDeletion$InProgressState,
        onConfirm: _confirm,
      ),
    );
  }
}
