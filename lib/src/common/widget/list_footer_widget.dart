import 'package:flutter/material.dart';
import 'package:youtube/src/common/theme/app_theme.dart';

/// Small spinner shown under a list while the next page loads.
class ListFooterWidget extends StatelessWidget {
  const ListFooterWidget({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(vertical: 16),
    child: Center(
      child: SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent),
      ),
    ),
  );
}
