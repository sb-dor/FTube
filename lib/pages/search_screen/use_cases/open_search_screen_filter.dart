import 'package:flutter/material.dart';
import 'package:youtube/pages/search_screen/presentation/layouts/search_screen_filter_screen.dart';

abstract class OpenSearchScreenFilter {
  static void openSearchScreenFilter(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return DraggableScrollableSheet(
            initialChildSize: 0.96,
            expand: false,
            builder: (context, scrollController) {
              return const SearchScreenFilterLayout();
            });
      },
    );
  }
}
