import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/utils/show_message.dart';
import 'package:youtube/src/feature/history_deletion/controller/history_deletion_controller.dart';
import 'package:youtube/src/feature/history_deletion/widgets/history_deletion_config_widget.dart';
import 'package:youtube/src/feature/library/widgets/confirmation_dialog_widget.dart';

class HistoryDeletionDialogWidget extends StatefulWidget {
  const HistoryDeletionDialogWidget({super.key});

  @override
  State<HistoryDeletionDialogWidget> createState() => _HistoryDeletionDialogWidgetState();
}

class _HistoryDeletionDialogWidgetState extends State<HistoryDeletionDialogWidget> {
  late final _scope = HistoryDeletionConfigInhWidget.of(context);
  late final _controller = _scope.historyDeletionController;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    final clearsAll = _scope.videoId == null;
    return StateConsumer<HistoryDeletionController, HistoryDeletionState>(
      controller: _controller,
      listener: (context, controller, previous, current) {
        if (current is HistoryDeletion$CompletedState) {
          _scope.onSuccessfullyDelete?.call();
          Navigator.pop(context);
        } else if (current is HistoryDeletion$ErrorState) {
          showMessage(context, message: l10n.errorGeneric, isError: true);
        }
      },
      builder: (context, state, _) => ConfirmationDialogWidget(
        title: clearsAll ? l10n.historyDeletionClearTitle : l10n.historyDeletionRemoveTitle,
        content: clearsAll ? l10n.historyDeletionClearContent : l10n.historyDeletionRemoveContent,
        confirmLabel: clearsAll ? l10n.historyDeletionClear : l10n.delete,
        inProgress: state is HistoryDeletion$InProgressState,
        onConfirm: _scope.confirm,
      ),
    );
  }
}
