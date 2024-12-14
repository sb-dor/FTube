import 'package:flutter/material.dart';
import 'package:youtube/features/search_screen/presentation/pages/layouts/search_screen_filter_screen.dart';

abstract class OpenSearchScreenFilter {
  static Future<void> openSearchScreenFilter(BuildContext context) async {
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.96,
          // expand: false,
          builder: (context, scrollController) {
            return const SearchScreenFilterLayout();
          },
        );
      },
    );
  }
}