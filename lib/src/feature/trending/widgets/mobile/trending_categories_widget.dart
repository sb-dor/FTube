import 'package:flutter/material.dart';
import 'package:youtube/src/common/localization/localization.dart';
import 'package:youtube/src/common/theme/app_theme.dart';
import 'package:youtube/src/feature/trending/models/trending_category.dart';

/// Horizontal row of trending category chips.
class TrendingCategoriesWidget extends StatelessWidget {
  const TrendingCategoriesWidget({required this.selected, required this.onSelected, super.key});

  final TrendingCategory selected;
  final ValueChanged<TrendingCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = Localization.of(context);
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: TrendingCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = TrendingCategory.values[index];
          final isSelected = category == selected;
          return ChoiceChip(
            label: Text(category.label(l10n)),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(category),
            selectedColor: AppColors.accent,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.accent),
            side: const BorderSide(color: AppColors.accent),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }
}
