import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/common/widget/dialog_messenger_widget.dart';

/// Confirmation dialog for destructive actions (history, playlists, playlist videos, downloads).
///
/// Can't be dismissed and shows a spinner instead of the buttons while [inProgress]. It has its
/// own messenger, so error snackbars shown with the context passed to [onConfirm] appear above it.
class ConfirmationDialogWidget extends StatelessWidget {
  const ConfirmationDialogWidget({
    required this.title,
    required this.content,
    required this.confirmLabel,
    required this.inProgress,
    required this.onConfirm,
    super.key,
  });

  final String title;
  final String content;
  final String confirmLabel;
  final bool inProgress;

  /// Called with the dialog's context, which sees the dialog's own messenger.
  final ValueChanged<BuildContext> onConfirm;

  @override
  Widget build(BuildContext context) => DialogMessengerWidget(
    builder: (dialogContext) => PopScope(
      canPop: !inProgress,
      child: AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: inProgress
            ? const [
                Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text(
                    Localization.of(dialogContext).cancel,
                    style: const TextStyle(color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: () => onConfirm(dialogContext),
                  child: Text(confirmLabel, style: const TextStyle(color: AppColors.accent)),
                ),
              ],
      ),
    ),
  );
}
