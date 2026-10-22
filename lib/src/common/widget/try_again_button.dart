import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';

/// Red pill button that retries a failed load, with an optional message above it.
class TryAgainButton extends StatelessWidget {
  const TryAgainButton({required this.onPressed, super.key, this.message});

  final VoidCallback onPressed;
  final String? message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message case final message?)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(message, textAlign: TextAlign.center),
          ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: onPressed,
          child: Text(Localization.of(context).tryAgain),
        ),
      ],
    ),
  );
}
