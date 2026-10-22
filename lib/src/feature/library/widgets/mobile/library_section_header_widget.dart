import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';

/// Section title with an optional red "+" button and an optional "See all" button.
class LibrarySectionHeaderWidget extends StatelessWidget {
  const LibrarySectionHeaderWidget({
    required this.title,
    super.key,
    this.onSeeAll,
    this.onAdd,
    this.addTooltip,
  });

  final String title;

  /// Hidden when null.
  final VoidCallback? onSeeAll;

  /// Hidden when null.
  final VoidCallback? onAdd;
  final String? addTooltip;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.9),
        ),
        if (onAdd case final onAdd?)
          IconButton(
            tooltip: addTooltip,
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: AppColors.accent),
          ),
        const Spacer(),
        if (onSeeAll case final onSeeAll?)
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: const BorderSide(color: AppColors.accent),
            ),
            onPressed: onSeeAll,
            child: Text(Localization.of(context).seeAll),
          ),
      ],
    ),
  );
}
