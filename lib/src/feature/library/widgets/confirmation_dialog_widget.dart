import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';

/// Confirmation dialog for destructive library actions (history, playlists).
///
/// Can't be dismissed and shows a spinner instead of the buttons while [inProgress].
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
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) => PopScope(
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
                onPressed: () => Navigator.pop(context),
                child: Text(
                  Localization.of(context).cancel,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              TextButton(
                onPressed: onConfirm,
                child: Text(confirmLabel, style: const TextStyle(color: AppColors.accent)),
              ),
            ],
    ),
  );
}
