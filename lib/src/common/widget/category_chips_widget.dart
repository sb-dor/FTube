import 'package:flutter/material.dart';
import 'package:youtube/src/common/theme/app_theme.dart';

/// Horizontal row of category chips (home feed, trending).
class CategoryChipsWidget<T> extends StatelessWidget {
  const CategoryChipsWidget({
    required this.values,
    required this.selected,
    required this.label,
    required this.onSelected,
    super.key,
  });

  final List<T> values;
  final T selected;

  /// The chip text for a category.
  final String Function(T value) label;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      itemCount: values.length,
      separatorBuilder: (_, _) => const SizedBox(width: 10),
      itemBuilder: (context, index) {
        final value = values[index];
        final isSelected = value == selected;
        return ChoiceChip(
          label: Text(label(value)),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => onSelected(value),
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
