import 'package:flutter/material.dart';
import 'package:youtube/src/common/theme/app_theme.dart';

/// A filter option: round indicator (red when [selected]) and its [label].
class SearchFilterRadioWidget extends StatelessWidget {
  const SearchFilterRadioWidget({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.accent : Colors.grey.shade500;
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Container(
                  width: 15,
                  height: 15,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  child: selected
                      ? DecoratedBox(
                          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                          child: const SizedBox.square(dimension: 10),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.9,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
